defmodule OffsiteWeb.DownloadComponent do
  use Phoenix.Component

  import ShorterMaps

  alias Offsite.{Downloaders.Download, Helpers}
  alias Timex.{Duration, Format.Duration.Formatters.Humanized}
  alias OffsiteWeb.DownloadComponent
  alias OffsiteWeb.Router.Helpers, as: RouteHelpers

  def render(assigns) do
    ~H"""
      <td class="download-row w-52 font-bold cursor-pointer" title={@download.id}> <%= @index + 1 %> </td>
      <td class="download-row w-52 underline text-blue-600 hover:text-blue-800 text-center whitespace-nowrap text-ellipsis overflow-hidden"> 
        <a href={@download.src}> <%= @download.name %> </a>
      </td>
      <td class="download-row"> <DownloadComponent.progress download={@download} /> </td>
      <td class="download-row"> <DownloadComponent.download_status download={@download} /> </td>
      <td class="download-row"> <%= get_speed(@download) %> </td>
      <td class="download-row"> <%= time_left(@download) %> </td>
      <td class="download-row"> <%= time_elapsed(@download) %> </td>
      <td class="download-row"> <DownloadComponent.actions download={@download} /> </td>
    """
  end

  def progress(%{download: ~M{%Download status, bytes_downloaded, size}} = assigns) do
    if status != :initiate && size != 0 do
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
        <span class="status-pill bg-yellow-500 text-yellow-50">Initiated</span>
        """

      :active ->
        ~H"""
        <span class="status-pill bg-blue-500 text-blue-50">Active</span>
        """

      :finish ->
        ~H"""
        <span class="status-pill bg-green-700 text-green-50">Finished</span>
        """

      :error ->
        ~H"""
        <span class="status-pill bg-red-500 text-red-50" title={@download.message |> inspect |> String.trim("\"")}>Error</span>
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

  def actions(%{download: ~M{%Download id, status}} = assigns) do
    ~H"""
    <div class="flex flex-row text-red justify-center gap-2">
      <%= if status == :finish do %>
        <a title="download" href={RouteHelpers.page_path(OffsiteWeb.Endpoint, :download, id)}>
          <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7 cursor-pointer transition duration-100 hover:scale-110" viewBox="0 0 20 20" fill="green">
            <path fill-rule="evenodd" d="M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm3.293-7.707a1 1 0 011.414 0L9 10.586V3a1 1 0 112 0v7.586l1.293-1.293a1 1 0 111.414 1.414l-3 3a1 1 0 01-1.414 0l-3-3a1 1 0 010-1.414z" clip-rule="evenodd" />
          </svg>
        </a>
      <% end %>

      <button title="Delete" data-confirm="Are you sure?" phx-click="delete" phx-value-id={id}>
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
