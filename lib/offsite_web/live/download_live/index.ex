defmodule OffsiteWeb.DownloadsLive.Index do
  use OffsiteWeb, :live_view

  import ShorterMaps

  alias OffsiteWeb.Router.Helpers, as: RouteHelpers

  alias Offsite.Downloaders.{Direct, Torrent}

  alias OffsiteWeb.Components.{
    AddDownloadComponent,
    DownloadComponent,
    TorrentDownloadComponent,
    HeaderComponent,
    VideoModal
  }

  @refresh_interval 300

  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :tick, 0)

    {:ok,
     assign(socket, %{
       tab: "direct",
       downloads: Direct.list(),
       torrent_downloads: Torrent.list(),
       play_modal: false
     })}
  end

  @impl true
  def handle_event("delete", %{"id" => id, "type" => "direct"}, socket) do
    Direct.remove(id)

    {:noreply, assign(socket, :downloads, Direct.list())}
  end

  @impl true
  def handle_event("delete", %{"id" => id, "type" => "torrent"}, socket) do
    Torrent.remove(id)

    {:noreply, socket}
  end

  @impl true
  def handle_event("change-tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :tab, tab)}
  end

  @impl true
  def handle_event("open-play-modal", ~m{id}, socket) do
    {:noreply,
     assign(
       socket,
       :play_modal,
       RouteHelpers.downloads_path(OffsiteWeb.Endpoint, :download, id)
     )}
  end

  @impl true
  def handle_event("close-play-modal", _params, socket) do
    {:noreply, assign(socket, :play_modal, false)}
  end

  @impl true
  def handle_info(:tick, socket) do
    socket =
      if socket.assigns.tab == "direct",
        do: assign(socket, :downloads, Direct.list()),
        else: assign(socket, :torrent_downloads, Torrent.list())

    Process.send_after(self(), :tick, @refresh_interval)
    {:noreply, socket}
  end

  # Helpers

  def active_tab_class("direct", "direct"), do: "bg-gray-300"
  def active_tab_class("direct", _tab), do: nil
  def active_tab_class("torrent", "torrent"), do: "bg-gray-300"
  def active_tab_class("torrent", _tab), do: nil
end
