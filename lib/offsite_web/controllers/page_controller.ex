defmodule OffsiteWeb.PageController do
  use OffsiteWeb, :controller

  def index(conn, _params) do
    # send_download(conn, {:file, "/home/arpan/Downloads/chromedriver_linux64.zip"})
    render(conn, "index.html")
  end
end
