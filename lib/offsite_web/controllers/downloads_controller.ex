defmodule OffsiteWeb.DownloadsController do
  use OffsiteWeb, :controller
  import ShorterMaps
  alias Offsite.Helpers
  alias Offsite.Downloaders.{Direct, Torrent, Download, TorrentDownload}
  require Logger

  def download(conn, params) do
    case get_file_from_params(params) do
      # For normal file download/streaming
      {:ok, ~M{%Download name, dest, size}} ->
        serve_download(conn, name, dest, size)

      # For torrent zip download
      {:ok, ~M{%TorrentDownload id, name, size}} ->
        zip_path = Offsite.Zipper.ZipperWorker.get_destination(id)
        serve_download(conn, "#{name}.zip", zip_path, size)

      # For torrent file download/streaming
      {:ok, ~m{name, length}} ->
        filename = Path.basename(name)
        serve_download(conn, filename, "#{Torrent.base_torrent_path()}/#{name}", length)

      _ ->
        send_resp(conn, 204, "")
    end
  end

  def get_file_from_params(params) do
    cond do
      params["type"] == "direct" ->
        Direct.get(params["id"])

      params["type"] == "torrent-file" && !is_nil(params["path"]) ->
        Torrent.get(params["id"], params["path"])

      params["type"] == "torrent-zip" ->
        Torrent.get(params["id"])

      true ->
        {:error, :unkown_request}
    end
  end

  # Supports partial/resumable ranged downloads(only supports 1 range).
  defp serve_download(conn, name, path, size) do
    if File.exists?(path) do
      # The range header is send for resumable downloads
      [range_start, range_end] =
        conn
        |> get_req_header("range")
        |> parse_range()

      # If range_end is missing consider size as range end
      size = Helpers.to_int(size)
      range_end = if !is_nil(range_end) && range_end > range_start, do: range_end, else: size
      length = range_end - range_start

      Logger.info("Serving #{path} range: bytes #{range_start}-#{range_start + length}/#{size}")

      # The "Accept-Ranges" header tells the client that we support partial/resumable download.
      # The "Content-Range" header gives the range in bytes in the format: "Content-Range: <unit> <range-start>-<range-end>/<size>""
      conn
      |> put_resp_header("content-length", inspect(length))
      |> put_resp_header("accept-ranges", "bytes")
      |> put_resp_header(
        "content-range",
        "bytes #{range_start}-#{range_start + length}/#{size}"
      )
      |> put_resp_header("content-disposition", "attachment; filename=\"#{name}\"")
      # 206 Partial Content
      |> send_file(206, path, range_start, length)
    else
      send_resp(conn, 204, "")
    end
  end

  # Parse the "range" header for resumable download byte offset
  # Header contains values like: "bytes=238590-"
  # References: 
  # https://stackoverflow.com/questions/157318/resumable-downloads-when-using-php-to-send-the-file
  # https://elixirforum.com/t/question-regarding-send-download-send-file-from-binary-in-memory/32507/3
  defp parse_range([]), do: [0, nil]

  defp parse_range([bytes | _]) do
    [range_start, range_end] = bytes |> String.trim_leading("bytes=") |> String.split("-")

    range_start = if range_start == "", do: 0, else: Helpers.to_int(range_start)
    range_end = if range_end == "", do: nil, else: Helpers.to_int(range_end)

    [range_start, range_end]
  end
end
