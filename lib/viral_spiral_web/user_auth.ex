defmodule ViralSpiralWeb.UserAuth do
  use ViralSpiralWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias ViralSpiral.Accounts

  # Atom key used with Plug.Conn session helpers (auto-converts to string internally)
  @session_key :user_id
  # String key used when reading the session map directly in LiveView on_mount callbacks
  @session_key_str "user_id"
  @max_age 60 * 60 * 24 * 60

  # --- Session helpers ---

  def log_in_user(conn, user, params \\ %{}) do
    return_to = get_session(conn, :return_to)

    conn
    |> renew_session()
    |> put_session(@session_key, user.id)
    |> maybe_remember_me(user.id, params)
    |> redirect(to: return_to || ~p"/platform/games")
  end

  def log_out_user(conn) do
    conn
    |> renew_session()
    |> delete_resp_cookie("remember_me")
    |> redirect(to: ~p"/login")
  end

  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  # Store the user_id in a signed cookie so the session survives browser restarts
  defp maybe_remember_me(conn, user_id, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, "remember_me", user_id,
      sign: true,
      max_age: @max_age,
      same_site: "Lax"
    )
  end

  defp maybe_remember_me(conn, _user_id, _params), do: conn

  # --- Plugs ---

  def fetch_current_user(conn, _opts) do
    user_id = get_session(conn, @session_key) || get_user_id_from_cookie(conn)
    assign(conn, :current_user, user_id && Accounts.get_user(user_id))
  end

  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_session(:return_to, conn.request_path)
      |> put_flash(:error, "You must be logged in to access this page.")
      |> redirect(to: ~p"/login")
      |> halt()
    end
  end

  def redirect_if_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn |> redirect(to: ~p"/platform/games") |> halt()
    else
      conn
    end
  end

  defp get_user_id_from_cookie(conn) do
    conn = fetch_cookies(conn, signed: ~w(remember_me))
    conn.cookies["remember_me"]
  end

  # --- LiveView on_mount hooks ---

  def on_mount(:fetch_current_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  def on_mount(:require_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must be logged in to access this page.")
        |> Phoenix.LiveView.redirect(to: ~p"/login")

      {:halt, socket}
    end
  end

  def on_mount(:redirect_if_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/platform/games")}
    else
      {:cont, socket}
    end
  end

  defp mount_current_user(socket, session) do
    # LiveView passes session as a map with string keys, not atoms
    user =
      case session[@session_key_str] do
        nil -> nil
        user_id -> Accounts.get_user(user_id)
      end

    Phoenix.Component.assign(socket, :current_user, user)
  end
end
