defmodule ViralSpiralWeb.UserAuth do
  use ViralSpiralWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias ViralSpiral.Accounts

  @session_key :user_id
  @max_age 60 * 60 * 24 * 60  # 60 days

  # --- Session helpers ---

  def log_in_user(conn, user, params \\ %{}) do
    conn
    |> renew_session()
    |> put_session(@session_key, user.id)
    |> maybe_remember_me(params)
    |> redirect(to: get_redirect_url(conn) || ~p"/")
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

  defp maybe_remember_me(conn, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, "remember_me", conn.assigns[:current_user_id] || "",
      sign: true,
      max_age: @max_age,
      same_site: "Lax"
    )
  end

  defp maybe_remember_me(conn, _params), do: conn

  defp get_redirect_url(conn) do
    get_session(conn, :return_to)
  end

  # --- Plugs ---

  def fetch_current_user(conn, _opts) do
    user_id = get_session(conn, @session_key) || get_user_id_from_cookie(conn)

    if user_id do
      assign(conn, :current_user, Accounts.get_user(user_id))
    else
      assign(conn, :current_user, nil)
    end
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
      conn |> redirect(to: ~p"/") |> halt()
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
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    else
      {:cont, socket}
    end
  end

  defp mount_current_user(socket, session) do
    user =
      case session[@session_key] do
        nil -> nil
        user_id -> Accounts.get_user(user_id)
      end

    Phoenix.Component.assign(socket, :current_user, user)
  end
end
