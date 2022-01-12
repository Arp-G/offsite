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
  end
end
