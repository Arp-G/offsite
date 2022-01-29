defmodule OffsiteWeb.Components.TorrentDownloadComponent do
  use Phoenix.Component

  import ShorterMaps

  alias Offsite.{Downloaders.TorrentDownload, Helpers}
  alias Timex.{Duration, Format.Duration.Formatters.Humanized}
  alias OffsiteWeb.Components.TorrentDownloadComponent
  alias OffsiteWeb.Router.Helpers, as: RouteHelpers

  def render(assigns) do
    ~H"""
      <td class="download-row w-52 font-bold cursor-pointer" title={@torrent.id}> <%= @index + 1 %> </td>
      <td class="download-row w-52 underline text-blue-600 hover:text-blue-800 text-center whitespace-nowrap text-ellipsis overflow-hidden"> 
        <a href={@torrent.magnetLink}> <%= @torrent.name %> </a>
      </td>
      <td class="download-row"> <TorrentDownloadComponent.progress download={@torrent} /> </td>
      <td class="download-row"> <TorrentDownloadComponent.download_status download={@torrent} /> </td>
      <td class="download-row"> <TorrentDownloadComponent.zipping_status download={@torrent} /> </td>
      <td class="download-row"> <TorrentDownloadComponent.get_speed download={@torrent} /> </td>
      <td class="download-row"> <%= time_left(@torrent) %> </td>
      <td class="download-row"> <TorrentDownloadComponent.actions download={@torrent} /> </td>
    """
  end

  def progress(
        %{download: ~M{%TorrentDownload status, percentDone, bytes_downloaded, size}} = assigns
      ) do
    if status != :initiate && size != 0 do
      percentage = percentDone * 100

      # Need to DRY
      ~H"""
      <div class="w-full bg-gray-200 rounded-full font-bold">
        <div class="leading-4 bg-green-600 font-bold text-center p-0.5 rounded-full h-5 transition-width" style={"width: #{percentage}%"}> 
          <%= trunc(percentage) %>% 
        </div>
      </div>
      <div class="mt-1"> <%= "#{Sizeable.filesize(bytes_downloaded)} / #{Sizeable.filesize(size)}" %> </div>
      """
    else
      ~H"""
      NA
      """
    end
  end

  def download_status(assigns) do
    status = assigns.download.status |> Atom.to_string() |> String.capitalize()

    cond do
      assigns.download.status in [:initiate, :stopped, :check_wait, :check, :download_wait] ->
        ~H"""
        <span class="status-pill bg-yellow-500 text-yellow-50"><%= status %></span>
        """

      assigns.download.status == :download ->
        ~H"""
        <span class="status-pill bg-blue-500 text-blue-50"><%= status %></span>
        """

      true ->
        ~H"""
        <span class="status-pill bg-green-700 text-green-50"><%= status %></span>
        """
    end
  end

  def zipping_status(assigns) do
    status = assigns.download.zip_status |> Atom.to_string() |> String.capitalize()

    cond do
      assigns.download.zip_status in [:pending, :enqueued] ->
        ~H"""
        <span class="status-pill bg-yellow-500 text-yellow-50"><%= status %></span>
        """

      assigns.download.zip_status in [:working, :done] ->
        ~H"""
        <span class="status-pill bg-green-700 text-green-50"><%= status %></span>
        """

      assigns.download.zip_status == :error ->
        ~H"""
        <span class="status-pill bg-red-700 text-red-50"><%= status %></span>
        """
    end
  end

  def time_left(~M{%TorrentDownload eta}) when is_nil(eta) or eta < 5, do: "NA"

  def time_left(~M{%TorrentDownload eta}) do
    eta
    |> Duration.from_seconds()
    |> Humanized.format()
  end

  def get_speed(%{download: ~M{%TorrentDownload rateDownload, rateUpload}} = assigns)
      when is_nil(rateDownload) or is_nil(rateUpload) do
    ~H"""
    NA
    """
  end

  def get_speed(%{download: ~M{%TorrentDownload rateDownload, rateUpload}} = assigns) do
    ~H"""
      <div class="flex flex-row mb-1" title="Download Speed">
        <div class="w-min pt-1">
          <svg enable-background="new 0 0 512 512" width="20" height="20" version="1.1" viewBox="0 0 512 512" xml:space="preserve" xmlns="http://www.w3.org/2000/svg">
            <polygon points="48.872 290.67 115.69 223.85 195.87 304.03 195.87 10.043 316.13 10.043 316.13 304.03 396.31 223.85 463.13 290.67 256 497.8" fill="#00B4D7"/>
            <polygon points="463.13 290.67 396.31 223.85 316.13 304.03 316.13 10.043 256 10.043 256 497.8" fill="#0093C4"/>
            <path d="M256,512L34.669,290.669l81.017-81.017l70.136,70.136V0h140.354v279.787l70.136-70.136l81.018,81.017L256,512z   M63.074,290.669L256,483.595l192.926-192.926l-52.614-52.613l-90.221,90.221V20.085H205.907v308.191l-90.221-90.221L63.074,290.669  z"/>
            <rect transform="matrix(-.7071 -.7071 .7071 -.7071 325.16 846.3)" x="327.81" y="268.4" width="20.085" height="174.81" fill="#fff"/>
          </svg>
        </div>
        <span class="pl-3 pt-1 text-xs whitespace-nowrap">
          <%= "#{rateDownload |> Sizeable.filesize()}/sec" %> 
        </span>
      </div>
      <hr/>
      <div class="flex flex-row" title="Upload Speed">
        <div class="w-min pt-1"> 
          <svg enable-background="new 0 0 512 512" width="20" height="20" version="1.1" viewBox="0 0 512 512" xml:space="preserve" xmlns="http://www.w3.org/2000/svg">
            <polygon points="463.13 221.33 396.31 288.15 316.13 207.97 316.13 501.96 195.87 501.96 195.87 207.97 115.69 288.15 48.871 221.33 256 14.202" fill="#00B4D7"/>
            <polygon points="48.871 221.33 115.69 288.15 195.87 207.97 195.87 501.96 256 501.96 256 14.202" fill="#0093C4"/>
            <path d="m326.18 512h-140.35v-279.79l-70.136 70.136-81.017-81.017 221.33-221.33 221.33 221.33-81.018 81.017-70.136-70.136v279.79zm-120.27-20.085h100.18v-308.19l90.221 90.221 52.614-52.613-192.93-192.93-192.93 192.93 52.613 52.613 90.221-90.221v308.19h1e-3z"/>
            <rect transform="matrix(-.7071 -.7071 .7071 -.7071 186.85 389.77)" x="164.1" y="68.783" width="20.085" height="174.81" fill="#fff"/>
          </svg>
        </div>
        <span class="pl-3 pt-1 text-xs whitespace-nowrap">
          <%= "#{rateUpload |> Sizeable.filesize()}/sec" %> 
        </span>
      </div>
    """
  end

  def actions(%{download: ~M{%TorrentDownload id, status}} = assigns) do
    ~H"""
    <div class="flex flex-row text-red justify-center gap-2" phx-click="open-modal-direct" phx-value-id={id} phx-value-type={"torrent-modal"}>
      <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7 cursor-pointer transition duration-100 hover:scale-110" viewBox="0 0 20 20" fill="green">
        <path fill-rule="evenodd" d="M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm3.293-7.707a1 1 0 011.414 0L9 10.586V3a1 1 0 112 0v7.586l1.293-1.293a1 1 0 111.414 1.414l-3 3a1 1 0 01-1.414 0l-3-3a1 1 0 010-1.414z" clip-rule="evenodd" />
      </svg>
    </div>
    <div class="flex flex-row text-red justify-center gap-2">
      <button title="Delete" data-confirm="Are you sure?" phx-click="delete" phx-value-id={id} phx-value-type={"torrent"}>
        <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7 cursor-pointer transition duration-100 hover:scale-110" fill="none" viewBox="0 0 24 24" stroke="red">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
        </svg>
      </button>
    </div>
    """
  end
end
