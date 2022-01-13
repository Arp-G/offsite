defmodule OffsiteWeb.DownloadComponent do
  use Phoenix.Component

  import ShorterMaps

  alias Offsite.{Downloaders.Download, Helpers}
  alias Timex.{Duration, Format.Duration.Formatters.Humanized}

  def render(assigns) do
    # <th>Id</th>
    # <th>Filename</th>
    # <th>Downloaded</th>
    # <th>Status</th>
    # <th>Speed</th>
    # <th>Time left</th>
    # <th>Started at</th>
    # <th>Actions</th>

    #   <div class="w-full bg-gray-200 h-1">
    #   <div class="bg-blue-600 h-1" style={"width: #{@download.bytes_downloaded / @download.size}%"}></div>
    # </div>

    # TODO: DRY tailwind classnames and make further live view functions components

    ~H"""
      <td class="px-6 py-3 text-center text-xs font-large w-52"> 
        <%= @index + 1 %> 
      </td>
      <td class="px-6 py-3 text-center text-xs font-large"> 
        <div class="w-52 underline text-blue-600 hover:text-blue-800 text-center whitespace-nowrap text-ellipsis overflow-hidden">
          <a href={@download.src}> <%= @download.name %> </a>
        </div>
      </td>
      <td class="px-6 py-3 text-center text-xs font-large"> <%= downloaded(@download) %> </td>
      <td class="px-6 py-3 text-center text-xs font-large"> <OffsiteWeb.DownloadComponent.download_status download={@download} /> </td>
      <td class="px-6 py-3 text-center text-xs font-large"> <%= get_speed(@download) %> </td>
      <td class="px-6 py-3 text-center text-xs font-large"> <%= time_left(@download) %> </td>
      <td class="px-6 py-3 text-center text-xs font-large"> <%= "#{time_elapsed(@download)} ago" %> </td>
      <td class="px-6 py-3 text-center text-xs font-large"> TBD </td>
    """
  end

  defp downloaded(~M{%Download status, bytes_downloaded, size})
       when status != :initiate and size != 0,
       do: "#{Sizeable.filesize(bytes_downloaded)} / #{Sizeable.filesize(size)}"

  defp downloaded(_), do: "NA"

  def download_status(assigns) do
    # TODO: colored status symbol
    ~H"""
      <%= inspect @download.status %>
    """
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

  def get_speed(download), do: "#{get_speed_in_bytes(download) |> Sizeable.filesize()}/sec"

  defp get_speed_in_bytes(~M{%Download bytes_downloaded, start_time}) when is_nil(start_time) or bytes_downloaded == 0, do: 0

  defp get_speed_in_bytes(~M{%Download bytes_downloaded, start_time}) do
    elapsed_time = DateTime.diff(DateTime.utc_now(), start_time)
    if elapsed_time == 0, do: 0, else: bytes_downloaded / elapsed_time
  end

  defp time_elapsed(~M{%Download start_time}) when is_nil(start_time), do: "NA"

  defp time_elapsed(~M{%Download start_time}) do
    DateTime.diff(DateTime.utc_now(), start_time)
    |> Duration.from_seconds()
    |> Humanized.format()
  end
end
