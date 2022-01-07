defmodule Offsite.Downloaders.Wget.Worker do
  use GenServer, restart: :temporary
  require Logger
  import ShorterMaps

  @script_path "./lib/offsite/downloaders/wget/script.js"

  # GenServer API

  # Using start instead of start_link to avoid the parent process from getting terminated when this worker terminates
  def start_link(args, opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  @impl GenServer
  def init(~M{id, src, dest, from}) do
    Logger.info("Start new wget worker: #{id}")
    # Makes your process call terminate/2 upon exit.
    Process.flag(:trap_exit, true)

    port =
      Port.open({:spawn, get_command(src, dest)}, [
        :binary,
        :exit_status
      ])

    Port.monitor(port)

    {:ok,
     ~M{id, src, dest, from, port, size: nil, status: :initiated, progress: nil, bytes_downloaded: nil, exit_status: nil, error_reason: nil}}
  end

  # terminate/2 is called if the GenServer traps exits
  @impl GenServer
  def terminate(reason, ~M{id, port, from} = state) do
    # Inform parent genserver
    Process.send(from, {:terminating, id, state}, [])

    Logger.info("Terminate wget-worker #{id}: reason=#{inspect(reason)} state=#{inspect(state)}")
    port_info = Port.info(port)
    os_pid = port_info[:os_pid]

    # Kill orphan OS process if any
    System.cmd("kill", ["-9", "#{os_pid}"])

    :normal
  end

  @impl GenServer
  def handle_call(:status, _from, state), do: {:reply, state, state}

  @impl GenServer
  def handle_info({port, {:data, "start:" <> filesize}}, ~M{port} = state) do
    {:noreply, %{state | size: filesize, status: :active}}
  end

  @impl GenServer
  def handle_info({port, {:data, "progress:" <> progress}}, ~M{port} = state) do
    {:noreply, %{state | progress: String.trim(progress)}}
  end

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
end
