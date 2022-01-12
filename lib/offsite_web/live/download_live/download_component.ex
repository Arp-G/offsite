defmodule OffsiteWeb.DownloadComponent do
  use Phoenix.Component

  import ShorterMaps

  alias Offsite.Downloaders.Download

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

    ~H"""
      <div class="m-2 bg-white shadow overflow-hidden sm:rounded-lg">
        <td> <%= @index + 1 %> </td>
        <td> <%= @download.name %> </td>
        <td> <%= @download.name %> </td>
        <td> <%= downloaded(@download) %> </td>
        <td> <OffsiteWeb.DownloadComponent.download_status download={@download} /> </td>
        <td> <%= @download.speed %> </td>
        <td> <%= time_left(@download) %> </td>
        <td> <%= inspect @download.start_time %> </td>
        <td> TBD </td>
      </div>
    """
  end


  defp downloaded(~M{%Download status, bytes_downloaded, size}) when status == :active and size != 0, do: "#{bytes_downloaded} / #{size}"
  defp downloaded(_), do: "NA"

  def download_status(assigns) do
    # TODO: colored status symbol
    ~H"""
      <%= inspect @download.status %>
    """
  end

  def time_left(~M{%Download status, speed, bytes_downloaded, size}) when status == :active and size != 0 and speed != 0 do
    (to_int(size) - to_int(bytes_downloaded)) / to_int(speed)
  end

  def time_left(_), do: "NA"

  def to_int(num) when is_binary(num) do
    case Integer.parse(num) do
      {num, _ } -> num
      :error -> 0
    end
  end
  
  def to_int(num), do: num
end