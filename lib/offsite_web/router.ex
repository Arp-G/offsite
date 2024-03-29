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

  scope "/" do
    pipe_through [:auth]

    forward "/rpc", ReverseProxyPlug,
      upstream: "http://127.0.0.1:9091/transmission/rpc",
      error_callback: &__MODULE__.log_reverse_proxy_error/1

    def log_reverse_proxy_error(error) do
      require Logger
      Logger.warn("ReverseProxyPlug network error: #{inspect(error)}")
    end
  end

  scope "/", OffsiteWeb do
    pipe_through [:browser, :auth]

    get "/download/:id", DownloadsController, :download
    live "/", DownloadsLive.Index, :index
    live_dashboard "/dashboard", metrics: OffsiteWeb.Telemetry
  end

  # Plug defination for Basic auth
  defp auth(conn, _opts) do
    username = get_env("AUTH_USERNAME") || "offsite"
    password = get_env("AUTH_PASSWORD") || "offsite"
    Plug.BasicAuth.basic_auth(conn, username: username, password: password)
  end

  defp get_env(env),
    do: with({:ok, value} <- System.fetch_env(env), do: value, else: (:error -> nil))
end
