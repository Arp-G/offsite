defmodule OffsiteWeb.CacheBodyReader do
  @moduledoc """
  Inspired by https://hexdocs.pm/plug/1.6.0/Plug.Parsers.html#module-custom-body-reader
  """

  alias Plug.Conn

  @doc """
  Read the raw body and store it for later use in the connection.
  It ignores the updated connection returned by `Plug.Conn.read_body/2` to not break CSRF.
  """
  @spec read_body(Conn.t(), Plug.opts()) :: {:ok, String.t(), Conn.t()}
  def read_body(%Conn{request_path: "/api/" <> _} = conn, opts) do
    {:ok, body, _conn} = Conn.read_body(conn, opts)
    conn = update_in(conn.assigns[:raw_body], &[body | &1 || []])
    {:ok, body, conn}
  end

  def read_body(conn, opts), do: Conn.read_body(conn, opts)
end
