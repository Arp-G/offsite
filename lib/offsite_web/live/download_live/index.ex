defmodule OffsiteWeb.DownloadsLive.Index do
  use OffsiteWeb, :live_view

  import ShorterMaps

  alias Offsite.Downloads
  alias OffsiteWeb.Components.{AddDownloadComponent, DownloadComponent, HeaderComponent}

  @refresh_interval 300

  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :tick, 0)
    {:ok, assign(socket, :downloads, Downloads.list_downloads())}
  end

  @impl true
  def handle_event("delete", ~m{id}, socket) do
    Downloads.delete_download(id)

    {:noreply, assign(socket, :downloads, Downloads.list_downloads())}
  end

  @impl true
  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, @refresh_interval)
    {:noreply, assign(socket, :downloads, Downloads.list_downloads())}
  end
end
