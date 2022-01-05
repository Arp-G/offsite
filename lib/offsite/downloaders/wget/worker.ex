defmodule Offsite.Downloaders.Wget.Worker do
  use GenServer
  require Logger
  import ShorterMaps

  @script_path "./lib/offsite/downloaders/wget/script.js"

  # Offsite.Downloader.Wget.start_link(%{src: "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_1920_18MG.mp4", dest: "/tmp/exp.vid"})

  # GenServer API
  def start_link(args, opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  @impl GenServer
  def init(~M{id, src, dest}) do
    # Makes your process call terminate/2 upon exit.
    Process.flag(:trap_exit, true)

    port =
      Port.open({:spawn, get_command(src, dest)}, [
        :binary,
        :exit_status
      ])

    Port.monitor(port)

    {:ok,
     ~M{id, src, dest, port, size: nil, status: :initiated, progress: nil, bytes_downloaded: nil, exit_status: nil, error_reason: nil}}
  end

  @impl GenServer
  # TODO INFORM CALLER
  def terminate(reason, ~M{port} = state) do
    Logger.info("Terminate wget-worker: reason=#{inspect(reason)} state=#{inspect(state)}")
    port_info = Port.info(port)
    os_pid = port_info[:os_pid]
    System.cmd("kill", ["-9", "#{os_pid}"])

    :normal
  end

  @impl GenServer
  def handle_call(:status, _from, state), do: {:reply, state, state}

  @impl GenServer
  def handle_cast(:cancel, state) do
    cleanup(state)
    {:stop, :cancel, %{state | status: :cancel, exit_status: :normal}}
  end

  @impl GenServer
  def handle_info({port, {:data, "start:" <> filesize}}, ~M{port} = state) do
    {:noreply, %{state | size: filesize, status: :active}}
  end

  @impl GenServer
  def handle_info({port, {:data, "progress:" <> progress}}, ~M{port} = state) do
    {:noreply, %{state | progress: String.trim(progress)}}
  end

  # TODO: wont get updated

  @impl GenServer
  def handle_info({port, {:data, "bytes:" <> bytes}}, ~M{port} = state) do
    {:noreply, %{state | bytes_downloaded: String.trim(bytes)}}
  end

  @impl GenServer
  def handle_info({port, {:data, "finish:" <> _msg}}, ~M{port, size} = state) do
    {:stop, :finish,
     %{
       state
       | status: :finish,
         progress: 1,
         bytes_downloaded: size,
         exit_status: :normal
     }}
  end

  @impl GenServer
  def handle_info({port, {:data, "error:" <> message}}, ~M{port} = state) do
    cleanup(state)
    {:stop, :error, %{state | status: :error, error_reason: message, exit_status: :error}}
  end

  @impl GenServer
  def handle_info({port, {:exit_status, status}}, ~M{port} = state) do
    {:stop, :exit, %{state | exit_status: status}}
  end

  @impl GenServer
  # DOWN messages sent by Process.monitor/1
  def handle_info({:DOWN, _ref, :port, _port, :normal}, state) do
    {:stop, :down, %{state | exit_status: :normal}}
  end

  @impl GenServer
  def handle_info({:EXIT, _port, :normal}, state) do
    {:stop, :exit, %{state | exit_status: :normal}}
  end

  @impl GenServer
  def handle_info(msg, state) do
    Logger.info("Unhandled message: #{inspect(msg)}")
    {:noreply, state}
  end

  defp get_command(src, dest), do: "#{@script_path} --src=#{src} --dest=#{dest}"

  defp cleanup(~M{dest}) do
    res = File.rm(dest)
    Logger.info("Remove left over file: #{inspect(res)}")
  end
end
