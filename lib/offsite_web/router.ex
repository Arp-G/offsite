defmodule OffsiteWeb.Router do
  use OffsiteWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {OffsiteWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OffsiteWeb do
    pipe_through [:browser, :auth]

    get "/download/:id", DownloadsController, :download
    live "/", DownloadsLive.Index, :index
    live_dashboard "/dashboard", metrics: OffsiteWeb.Telemetry
  end

  # Plug defination for Basic auth
  defp auth(conn, _opts) do
    username = System.fetch_env!("AUTH_USERNAME")
    password = System.fetch_env!("AUTH_PASSWORD")
    Plug.BasicAuth.basic_auth(conn, username: username, password: password)
  end
end
