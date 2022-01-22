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

  scope "/" do
    pipe_through :api

    forward "/rpc", ReverseProxyPlug,
      upstream: "http://127.0.0.1:9091/transmission/rpc",
      error_callback: &__MODULE__.log_reverse_proxy_error/1

    def log_reverse_proxy_error(error) do
      require Logger
      Logger.warn("ReverseProxyPlug network error: #{inspect(error)}")
    end
  end

  # Plug defination for Basic auth
  defp auth(conn, _opts) do
    username = System.fetch_env!("AUTH_USERNAME")
    password = System.fetch_env!("AUTH_PASSWORD")
    Plug.BasicAuth.basic_auth(conn, username: username, password: password)
  end
end
