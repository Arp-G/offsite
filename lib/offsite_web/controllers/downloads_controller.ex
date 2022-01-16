defmodule OffsiteWeb.DownloadsController do
  use OffsiteWeb, :controller
  import ShorterMaps
  alias Offsite.Downloads
  alias Offsite.Downloaders.Download

  def download(conn, ~m{id}) do
    case Downloads.get_download(id) do
      {:ok, ~M{%Download name, dest}} -> send_download(conn, {:file, dest}, filename: name)
      {:error, _} -> send_resp(conn, 204, "")
    end
  end
end
