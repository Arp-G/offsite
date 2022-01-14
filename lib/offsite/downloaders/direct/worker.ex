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
    Process.send_after(self(), :kickoff, 0)

    {
      :ok,
      ~M{
        id, src, dest, from, size: 0, status: :initiate,
        bytes_downloaded: 0, exit_status: nil, error_reason: nil,
        start_time: nil, end_time: nil, resp: nil, fd: nil
      }
    }
  end

  # terminate/2 is called if the GenServer traps exits
  @impl GenServer
  def terminate(reason, ~M{id, from} = state) do
    # Inform parent genserver
    Process.send(from, {:terminating, id, state}, [])

    Logger.info(
      "Terminate download-worker #{id}: reason=#{inspect(reason)} state=#{inspect(state)}"
    )

    state
    |> Map.get(state, :fd)
    |> File.close()

    :normal
  end

  @impl GenServer
  def handle_call(:status, _from, state), do: {:reply, state, state}

  @impl GenServer
  def handle_info(:kickoff, ~M{src, dest} = state) do
    {:ok, fd} = File.open(dest, [:write, :binary])

    case HTTPoison.get(src, %{}, stream_to: self(), async: :once) do
      {:ok, resp} ->
        {:noreply, ~M{state | resp, fd}}

      {:error, ~M{%HTTPoison.Error reason}} ->
        {:stop, reason, ~M{state | status: :error, error_reason: reason, exit_status: :error}}
    end
  end

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
        ~M{resp, fd, bytes_downloaded} = state
      ) do
    IO.binwrite(fd, chunk)
    HTTPoison.stream_next(resp)
    bytes_downloaded = bytes_downloaded + byte_size(chunk)
    {:noreply, ~M{state | bytes_downloaded}}
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
end
