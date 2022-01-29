defmodule Offsite.Zipper.ZipperWorker do
  use GenServer
  require Logger

  alias Offsite.{Zipper.ZipperQueue, Downloaders.Torrent}

  @base_zip_dest "/tmp/torrents_zip"
  @check_for_work_interval 1000

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def remove_zip(id) do
    resp =
      id
      |> get_destination()
      |> File.rm()

    Logger.info("Remove zip file #{get_destination(id)}: #{inspect(resp)}")
    resp
  end

  # Callbacks

  @impl true
  def init(_args) do
    Process.send_after(self(), :work, @check_for_work_interval)
    {:ok, :no_op}
  end

  @impl true
  def handle_info(:work, state) do
    case ZipperQueue.get_work() do
      {id, src_path} ->
        dest_path = get_destination(id)

        # TODO: Find low cpu usage no compression zipping option
        command = "zip -r '#{dest_path}' '#{src_path}'"

        Logger.info("Start zipping: #{command}")

        Torrent.update_zipping_status(id, :working)
        {resp, exit_status} = System.shell(command)

        Logger.info("Done zipping: #{inspect(resp)}")

        if exit_status == 0 && File.exists?(dest_path),
          do: Torrent.update_zipping_status(id, :done),
          else: Torrent.update_zipping_status(id, :error)

      :no_work ->
        nil

      bad_work ->
        Logger.warn("Ignoring bad work: #{inspect(bad_work)}")
        nil
    end

    Process.send_after(self(), :work, @check_for_work_interval)

    {:noreply, state}
  end

  defp get_destination(id) do
    "#{@base_zip_dest}/#{id}.zip"
  end
end
