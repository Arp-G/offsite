defmodule OffsiteWeb.DownloadsController do
  use OffsiteWeb, :controller
  import ShorterMaps
  alias Offsite.Downloads
  alias Offsite.Downloaders.Download

  def download(conn, ~m{id}) do
    case Downloads.get_download(id) do
      {:ok, ~M{%Download name, dest, size}} ->
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
        |> send_file(206, dest, bytes_offset, Offsite.Helpers.to_int(size) - bytes_offset)

      {:error, _} ->
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
