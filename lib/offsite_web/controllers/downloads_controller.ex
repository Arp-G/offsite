defmodule OffsiteWeb.DownloadsController do
  use OffsiteWeb, :controller
  import ShorterMaps
  alias Offsite.Downloaders.{Direct, Torrent, Download, TorrentDownload}

  @torrent_base_path "/tmp/torrents"

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
        serve_download(conn, filename, "#{@torrent_base_path}/#{name}", length)

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

  defp serve_download(conn, name, path, size) do
    if File.exists?(path) do
      # The range header is send for resumable downloads
      bytes_offset =
        conn
        |> get_req_header("range")
        |> parse_range()

      # The "Accept-Ranges" header tells the client that we support partial/resumable download.
      # The "Content-Range" header gives the range in bytes in the format: "Content-Range: <unit> <range-start>-<range-end>/<size>""
      conn
      |> put_resp_header("accept-ranges", "bytes")
      |> put_resp_header(
        "content-range",
        "bytes #{bytes_offset}-#{Offsite.Helpers.to_int(size) - 1}/#{size}"
      )
      |> put_resp_header("content-disposition", "attachment; filename=\"#{name}\"")
      # 206 Partial Content
      |> send_file(206, path, bytes_offset, Offsite.Helpers.to_int(size) - bytes_offset)
    else
      send_resp(conn, 204, "")
    end
  end

  # Parse the "range" header for resumable download byte offset
  # Header contains values like: "bytes=238590-"
  # References: 
  # https://stackoverflow.com/questions/157318/resumable-downloads-when-using-php-to-send-the-file
  # https://elixirforum.com/t/question-regarding-send-download-send-file-from-binary-in-memory/32507/3
  defp parse_range(req_range_header) when req_range_header == [], do: 0

  defp parse_range([bytes | _]) do
    [range_start, _range_end] =
      bytes
      |> String.trim_leading("bytes=")
      |> String.split("-")

    String.to_integer(range_start)
  end
end
