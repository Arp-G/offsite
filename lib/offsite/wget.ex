defmodule Offsite.Downloader.Wget do
  use GenServer
  require Logger
  import ShorterMaps

  @script_path "./lib/offsite/wget.js"

  # Offsite.Downloader.Wget.start_link(%{src: "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_1920_18MG.mp4", dest: "/tmp/exp.vid"})

  # TODO: shorter maps won't work for some reason

  # GenServer API
  def start_link(args, opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def init(~M{src, dest}) do
    # Makes your process call terminate/2 upon exit.
    Process.flag(:trap_exit, true)

    port =
      Port.open({:spawn, get_command(src, dest)}, [
        :binary,
        :exit_status
      ])

    Port.monitor(port)

    {:ok,
     %{
       src: src,
       dest: dest,
       port: port,
       latest_progress: nil,
       latest_bytes: nil,
       exit_status: nil,
       size: nil,
       status: "initiated",
       error_reason: nil
     }}
  end

  def terminate(reason, ~M{port} = state) do
    Logger.info("Terminate wget-worker: reason=#{inspect(reason)} state=#{inspect(state)}")
    port_info = Port.info(port)
    os_pid = port_info[:os_pid]
    System.cmd("kill", ["-9", "#{os_pid}"])

    :normal
  end

  def handle_cast("canceled", state) do
    cleanup(state)
    {:stop, "cancel", %{state | status: "canceled", exit_status: :normal}}
  end

  def handle_info({port, {:data, "start:" <> filesize}}, ~M{port} = state) do
    {:noreply, %{state | size: filesize, status: "active"}}
  end

  def handle_info({port, {:data, "progress:" <> progress}}, ~M{port} = state) do
    {:noreply, %{state | latest_progress: String.trim(progress)}}
  end

  def handle_info({port, {:data, "bytes:" <> bytes}}, ~M{port} = state) do
    {:noreply, %{state | latest_bytes: String.trim(bytes)}}
  end

  def handle_info({port, {:data, "finish:" <> _msg}}, ~M{port} = state) do
    {:stop, "finish", %{state | status: "finish", exit_status: :normal}}
  end

  def handle_info({port, {:data, "error:" <> message}}, ~M{port} = state) do
    cleanup(state)
    {:stop, "error", %{state | status: "error", error_reason: message, exit_status: :error}}
  end

  def handle_info({port, {:exit_status, status}}, ~M{port} = state) do
    {:stop, "exit", %{state | exit_status: status}}
  end

  def handle_info({:DOWN, _ref, :port, _port, :normal}, state) do
    {:stop, "down", %{state | exit_status: :normal}}
  end

  def handle_info({:EXIT, _port, :normal}, state) do
    {:stop, "EXIT", %{state | exit_status: :normal}}
  end

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
