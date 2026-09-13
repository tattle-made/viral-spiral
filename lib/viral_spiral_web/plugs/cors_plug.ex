defmodule ViralSpiralWeb.CORSPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_header("access-control-allow-origin", "*")
    |> put_resp_header("access-control-allow-methods", "GET, POST, PUT, DELETE, OPTIONS")
    |> put_resp_header("access-control-allow-headers", "content-type, authorization")
    |> handle_preflight(conn.method)
  end

  defp handle_preflight(conn, "OPTIONS") do
    conn |> send_resp(204, "") |> halt()
  end
  defp handle_preflight(conn, _), do: conn
end
