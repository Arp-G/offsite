defmodule OffsiteWeb.DownloadsLive.Index do
  use OffsiteWeb, :live_view

  import ShorterMaps

  alias Offsite.Downloads

  @refresh_interval 300

  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :tick, 0)
    {:ok, assign(socket, :downloads, list_downloads())}
  end

  @impl true
  def handle_event("delete", ~M{id}, socket) do
    Downloads.delete_download(id)

    {:noreply,
     socket
     |> put_flash(:info, "Download created successfully")
     |> assign(:downloads, list_downloads())}
  end

  @impl true
  def handle_info(:tick, %{assigns: assigns} = socket) do
    Process.send_after(self(), :tick, @refresh_interval)
    {:noreply, assign(socket, :downloads, list_downloads())}
  end

  defp list_downloads do
    Downloads.list_downloads()

    # %{
    #   "1f80d5c2-74ab-11ec-91b1-5e621e2e41ff" => %Offsite.Downloaders.Download{
    #     bytes_downloaded: 3_346_708,
    #     dest: "/tmp/1f80d5c2-74ab-11ec-91b1-5e621e2e41ff",
    #     end_time: nil,
    #     id: "1f80d5c2-74ab-11ec-91b1-5e621e2e41ff",
    #     message: nil,
    #     name: "file_example_MP4_1920_18MG.mp4",
    #     pid: nil,
    #     size: "17839845",
    #     src: "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_1920_18MG.mp4",
    #     start_time: ~U[2022-01-13 19:58:06.188985Z],
    #     status: :active,
    #     type: :normal
    #   }
    # }
  end
end
