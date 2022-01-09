defmodule Offsite.Downloaders.Direct.Worker do
  use GenServer, restart: :temporary
  require Logger
  import ShorterMaps

  # GenServer API

  def start_link(args, opts \\ []), do: GenServer.start_link(__MODULE__, args, opts)

  @impl GenServer
  def init(~M{id, src, dest, from}) do
    Logger.info("Start new wget worker: #{id}")
    # Makes your process call terminate/2 upon exit.
    Process.flag(:trap_exit, true)

    resp = HTTPoison.get!(src, %{}, stream_to: self(), async: :once)
    {:ok, fd} = File.open(dest, [:write, :binary])

    {
      :ok,
      ~M{
        resp, fd, id, src, dest, from, size: 0, status: :initiated,
        bytes_downloaded: 0, exit_status: nil, error_reason: nil,
        start_time: nil, end_time: nil, speed: 0
      }
    }
  end

  # terminate/2 is called if the GenServer traps exits
  @impl GenServer
  def terminate(reason, ~M{id, fd, dest, from} = state) do
    # Inform parent genserver
    Process.send(from, {:terminating, id, state}, [])

    Logger.info(
      "Terminate download-worker #{id}: reason=#{inspect(reason)} state=#{inspect(state)}"
    )

    # Remove file
    File.close(fd)
    File.rm(dest)

    :normal
  end

  @impl GenServer
  def handle_call(:status, _from, state), do: {:reply, state, state}

  @impl GenServer
  def handle_info(~M{%HTTPoison.AsyncStatus code}, state) when code >= 400 do
    message = "Failed with code: #{code}"
    {:stop, message, ~M{state | status: :error, error_reason: message, exit_status: :error}}
  end

  @impl GenServer
  def handle_info(~M{%HTTPoison.AsyncStatus}, ~M{resp} = state) do
    HTTPoison.stream_next(resp)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(~M{%HTTPoison.AsyncHeaders headers}, ~M{resp} = state) do
    size =
      Enum.find(headers, fn
        {"Content-Length", _length} -> true
        _ -> false
      end)
      |> case do
        {"Content-Length", length} -> length || 0
        false -> 0
      end

    HTTPoison.stream_next(resp)
    {:noreply, ~M{state | size, status: :active, start_time: DateTime.utc_now()}}
  end

  @impl GenServer
  def handle_info(
        ~M{%HTTPoison.AsyncChunk chunk},
        ~M{start_time, resp, fd, bytes_downloaded} = state
      ) do
    IO.binwrite(fd, chunk)
    HTTPoison.stream_next(resp)
    bytes_downloaded = bytes_downloaded + byte_size(chunk)
    {:noreply, ~M{state | bytes_downloaded, speed: calc_speed(start_time, bytes_downloaded)}}
  end

  @impl GenServer
  def handle_info(~M{%HTTPoison.AsyncEnd}, ~M{fd} = state) do
    File.close(fd)

    {
      :stop,
      :finish,
      ~M{state | status: :finish, exit_status: :normal, end_time: DateTime.utc_now()}
    }
  end

  defp calc_speed(start_time, bytes_downloaded) do
    elapsed_time = DateTime.diff(DateTime.utc_now(), start_time)

    # Logger.info( "speed = #{if elapsed_time == 0, do: 0, else: Sizeable.filesize(bytes_downloaded / elapsed_time)}")
    if elapsed_time == 0, do: 0, else: Sizeable.filesize(bytes_downloaded / elapsed_time)
  end
end
