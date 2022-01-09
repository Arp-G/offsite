defmodule OffsiteWeb.DownloadsLive.Index do
  use OffsiteWeb, :live_view

  alias Offsite.Downloads

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :downloads, list_downloads())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Downloads.delete_download(id)

    {:noreply,
     socket
     |> put_flash(:info, "Download created successfully")
     |> assign(:downloads, list_downloads())}
  end

  defp list_downloads do
    Downloads.list_downloads()
  end
end
