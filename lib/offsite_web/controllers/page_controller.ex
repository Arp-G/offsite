defmodule OffsiteWeb.PageController do
  use OffsiteWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
