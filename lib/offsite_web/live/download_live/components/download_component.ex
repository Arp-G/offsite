defmodule OffsiteWeb.Components.DownloadComponent do
  use Phoenix.Component

  import ShorterMaps

  alias Offsite.{Downloaders.Download, Helpers}
  alias Timex.{Duration, Format.Duration.Formatters.Humanized}
  alias OffsiteWeb.Components.DownloadComponent
  alias OffsiteWeb.Router.Helpers, as: RouteHelpers

  def render(assigns) do
    ~H"""
      <td class="px-6 py-3 text-center text-xs font-medium w-52 font-bold cursor-pointer" title={@download.id}> <%= @index + 1 %> </td>
      <td class="px-6 py-3 text-center text-xs font-medium w-52 underline text-blue-600 hover:text-blue-800 text-center whitespace-nowrap text-ellipsis overflow-hidden">
        <a href={@download.src}> <%= @download.name %> </a>
      </td>
      <td class="px-6 py-3 text-center text-xs font-medium"> <DownloadComponent.progress download={@download} /> </td>
      <td class="px-6 py-3 text-center text-xs font-medium"> <DownloadComponent.download_status download={@download} /> </td>
      <td class="px-6 py-3 text-center text-xs font-medium"> <%= get_speed(@download) %> </td>
      <td class="px-6 py-3 text-center text-xs font-medium"> <%= time_left(@download) %> </td>
      <td class="px-6 py-3 text-center text-xs font-medium"> <%= time_elapsed(@download) %> </td>
      <td class="px-6 py-3 text-center text-xs font-medium"> <DownloadComponent.actions download={@download} /> </td>
    """
  end

  def progress(%{download: ~M{%Download status, bytes_downloaded, size}} = assigns) do
    if status != :initiate && Helpers.to_int(size) != 0 do
      percentage = bytes_downloaded / Helpers.to_int(size) * 100

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
    case assigns.download.status do
      :initiate ->
        ~H"""
        <span class="py-1 px-2 rounded-full text-xs font-bold ml-1 bg-yellow-500 text-yellow-50">Initiated</span>
        """

      :active ->
        ~H"""
        <span class="py-1 px-2 rounded-full text-xs font-bold ml-1 bg-blue-500 text-blue-50">Active</span>
        """

      :finish ->
        ~H"""
        <span class="py-1 px-2 rounded-full text-xs font-bold ml-1 bg-green-700 text-green-50">Finished</span>
        """

      :error ->
        ~H"""
        <span class="py-1 px-2 rounded-full text-xs font-bold ml-1 bg-red-500 text-red-50" title={@download.message |> inspect |> String.trim("\"")}>Error</span>
        """
    end
  end

  def time_left(~M{%Download status, bytes_downloaded, size} = download)
      when status == :active and size != 0 and bytes_downloaded != 0 do
    speed = get_speed_in_bytes(download)

    if speed > 0,
      do:
        ((Helpers.to_int(size) - bytes_downloaded) / speed)
        |> trunc
        |> Duration.from_seconds()
        |> Humanized.format(),
      else: "NA"
  end

  def time_left(_), do: "NA"

  def get_speed(download) when download.status == :active,
    do: "#{get_speed_in_bytes(download) |> Sizeable.filesize()}/sec"

  def get_speed(_download), do: "NA"

  def actions(%{download: ~M{%Download id, status, name}} = assigns) do
    ~H"""
    <div class="flex flex-row text-red justify-center gap-2">
      <%= if status == :finish do %>
        <a title="download" href={RouteHelpers.downloads_path(OffsiteWeb.Endpoint, :download, id, type: "direct")}>
          <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7 cursor-pointer transition duration-100 hover:scale-110" viewBox="0 0 20 20" fill="green">
            <path fill-rule="evenodd" d="M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm3.293-7.707a1 1 0 011.414 0L9 10.586V3a1 1 0 112 0v7.586l1.293-1.293a1 1 0 111.414 1.414l-3 3a1 1 0 01-1.414 0l-3-3a1 1 0 010-1.414z" clip-rule="evenodd" />
          </svg>
        </a>
      <% end %>

      <%= if Helpers.playable_extention(name) do %>
        <button title="Play" phx-click="open-modal-direct" phx-value-type={"play-modal-direct"} phx-value-id={id}>
          <svg class="h-6 w-6 cursor-pointer transition duration-100 hover:scale-110" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" id="Layer_1" x="0px" y="0px" viewBox="0 0 502.119 502.119" style="enable-background:new 0 0 502.119 502.119;" xml:space="preserve" width="512" height="512"> <g> <g>
            <path style="fill:#4D93E8;" d="M131.743,17.904L421.08,213.57c26.539,17.947,26.539,57.031,0,74.978L131.743,484.215 c-30.055,20.325-70.609-1.207-70.609-37.489V55.393C61.134,19.111,101.688-2.421,131.743,17.904z"/> <path d="M106.489,502.119c-8.834,0-17.716-2.185-26.01-6.589c-18.375-9.756-29.345-28-29.345-48.804V55.393 c0-20.804,10.97-39.048,29.345-48.804c18.373-9.756,39.634-8.622,56.865,3.032l289.337,195.667 c15.218,10.291,24.303,27.402,24.303,45.772s-9.085,35.481-24.303,45.772L137.345,492.498 C127.892,498.891,117.226,502.119,106.489,502.119z M106.454,20.05c-5.637,0-11.304,1.394-16.596,4.204 c-11.725,6.225-18.724,17.866-18.724,31.14v391.333c0,13.274,6.999,24.915,18.724,31.14c11.723,6.226,25.287,5.501,36.283-1.935 l289.337-195.667c9.854-6.664,15.506-17.309,15.506-29.205c0-11.896-5.651-22.541-15.506-29.205L126.142,26.188 C120.109,22.109,113.304,20.05,106.454,20.05z"/> </g> <g> <path d="M351.051,216.06c-1.932,0-3.882-0.558-5.602-1.723l-16.236-11.003c-4.571-3.098-5.767-9.316-2.668-13.888 c3.1-4.572,9.316-5.765,13.889-2.668l16.236,11.003c4.571,3.098,5.767,9.316,2.668,13.888 C357.404,214.522,354.256,216.06,351.051,216.06z"/> </g> <g> <path d="M304.051,184.209c-1.932,0-3.882-0.558-5.602-1.723l-195-132.149c-4.571-3.099-5.767-9.316-2.668-13.888 c3.1-4.572,9.316-5.765,13.889-2.668l195,132.149c4.571,3.099,5.767,9.316,2.668,13.888 C310.404,182.671,307.256,184.209,304.051,184.209z"/> </g> </g>
          </svg>
        </button>
      <% end %>

      <button title="Delete" data-confirm="Are you sure?" phx-click="delete" phx-value-id={id} phx-value-type={"direct"}>
        <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7 cursor-pointer transition duration-100 hover:scale-110" fill="none" viewBox="0 0 24 24" stroke="red">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
        </svg>
      </button>
    </div>
    """
  end

  # Private Helpers

  defp get_speed_in_bytes(~M{%Download bytes_downloaded, start_time})
       when is_nil(start_time) or bytes_downloaded == 0,
       do: 0

  defp get_speed_in_bytes(~M{%Download bytes_downloaded, start_time}) do
    elapsed_time = DateTime.diff(DateTime.utc_now(), start_time)
    if elapsed_time == 0, do: 0, else: bytes_downloaded / elapsed_time
  end

  defp time_elapsed(~M{%Download start_time}) when is_nil(start_time), do: "NA"

  defp time_elapsed(~M{%Download status, start_time, end_time}) do
    if(status == :finish, do: end_time, else: DateTime.utc_now())
    |> DateTime.diff(start_time)
    |> Duration.from_seconds()
    |> Humanized.format()
  end
end
