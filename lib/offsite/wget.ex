defmodule Offsite.Downloader.Wget do
  use GenServer
  require Logger
  # import ShorterMaps

  @script_path "/home/arpan/dev/offsite/lib/offsite/wget.js"

  # Offsite.Downloader.Wget.start_link(%{src: "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_1920_18MG.mp4", dest: "/tmp/exp.vid"})

  # TODO: shorter maps won't work for some reason

  # GenServer API
  def start_link(args, opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def init(%{src: src, dest: dest}) do
    Process.flag(:trap_exit, true)

    port =
      Port.open({:spawn, get_command(src, dest)}, [
        :binary,
        :exit_status
      ])

    Port.monitor(port)

    {:ok, %{port: port, latest_progress: nil, latest_bytes: nil, exit_status: nil}}
  end

  defp get_command(src, dest), do: "#{@script_path} --src=#{src} --dest=#{dest}"

  def terminate(reason, %{port: port} = state) do
    Logger.info(
      "** TERMINATE: #{inspect(reason)}. This is the last chance to clean up after this process."
    )

    Logger.info("Final state: #{inspect(state)}")

    port_info = Port.info(port)
    os_pid = port_info[:os_pid]

    Logger.warn("Orphaned OS process: #{os_pid}")

    :normal
  end

  # This callback handles data incoming from the command's STDOUT
  def handle_info({port, {:data, "progress:" <> progress}}, %{port: port} = state) do
    Logger.info("Progress: #{inspect(progress)}")
    {:noreply, %{state | latest_progress: String.trim(progress)}}
  end

  def handle_info({port, {:data, "bytes:" <> bytes}}, %{port: port} = state) do
    Logger.info("Bytes: #{inspect(bytes)}")
    {:noreply, %{state | latest_bytes: String.trim(bytes)}}
  end

  def handle_info({port, {:data, other}}, %{port: port} = state) do
    Logger.info("Other: #{inspect(other)}")
    {:noreply, state}
  end

  # This callback tells us when the process exits
  def handle_info({port, {:exit_status, status}}, %{port: port} = state) do
    Logger.info("Port exit: :exit_status: #{status}")

    new_state = %{state | exit_status: status}

    {:noreply, new_state}
  end

  def handle_info({:DOWN, _ref, :port, port, :normal}, state) do
    Logger.info("Handled :DOWN message from port: #{inspect(port)}")
    {:noreply, state}
  end

  def handle_info({:EXIT, port, :normal}, state) do
    Logger.info("handle_info: EXIT")
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.info("Unhandled message: #{inspect(msg)}")
    {:noreply, state}
  end
end
