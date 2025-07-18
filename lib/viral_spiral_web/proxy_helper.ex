defmodule ViralSpiralWeb.ProxyHelper do
  def proxy_path(conn, path) do
    if conn.assigns[:inside_discord] && !String.starts_with?(path, "/.proxy/") do
      "/.proxy" <> path
    else
      path
    end
  end
end
