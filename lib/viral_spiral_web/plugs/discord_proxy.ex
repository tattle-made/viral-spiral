defmodule ViralSpiralWeb.Plugs.DiscordProxy do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = fetch_query_params(conn)

    discord? =
      conn.params["frame_id"] ||
        get_session(conn, "discord_frame_id")

    IO.inspect(!!discord?, label: "FROM PLUG, INSIDE DISCORD? ")

    assign(conn, :inside_discord, !!discord?)
  end
end
