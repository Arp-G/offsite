defmodule OffsiteWeb.DownloadsLive.Index do
  use OffsiteWeb, :live_view

  import ShorterMaps

  alias OffsiteWeb.Router.Helpers, as: RouteHelpers
  alias Offsite.Downloads
  alias Offsite.Downloaders.Download

  alias OffsiteWeb.Components.{
    AddDownloadComponent,
    DownloadComponent,
    HeaderComponent,
    VideoModal
  }

  @refresh_interval 300

  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :tick, 0)
    {:ok, assign(socket, %{downloads: Downloads.list_downloads(), play_modal: false})}
  end

  @impl true
  def handle_event("delete", ~m{id}, socket) do
    Downloads.delete_download(id)

    {:noreply, assign(socket, :downloads, Downloads.list_downloads())}
  end

  @impl true
  def handle_event(
        "open-play-modal",
        ~m{id},
        %Phoenix.LiveView.Socket{assigns: ~M{downloads}} = socket
      ) do
    {:noreply,
     assign(
       socket,
       :play_modal,
       RouteHelpers.downloads_path(OffsiteWeb.Endpoint, :download, id)
     )}
  end

  @impl true
  def handle_event("close-play-modal", _params, socket) do
    IO.inspect("modal close")
    {:noreply, assign(socket, :play_modal, false)}
  end

  @impl true
  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, @refresh_interval)
    {:noreply, assign(socket, :downloads, Downloads.list_downloads())}
  end
end
