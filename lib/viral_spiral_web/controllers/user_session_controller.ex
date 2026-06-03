defmodule ViralSpiralWeb.UserSessionController do
  use ViralSpiralWeb, :controller

  alias ViralSpiral.Accounts
  alias ViralSpiral.Invitations
  alias ViralSpiralWeb.UserAuth

  @token_salt "user_login"
  @token_max_age 60

  @doc """
  Called after a LiveView login/registration succeeds.
  The LiveView signs user_id into a short-lived URL token and redirects here.
  This controller verifies the token, accepts any pending invite, then writes the session.
  """
  def create(conn, %{"token" => token} = params) do
    case Phoenix.Token.verify(ViralSpiralWeb.Endpoint, @token_salt, token, max_age: @token_max_age) do
      {:ok, user_id} ->
        user = Accounts.get_user!(user_id)
        maybe_accept_invite(params["invite_token"], user, conn)
        UserAuth.log_in_user(conn, user, params)

      {:error, _} ->
        conn
        |> put_flash(:error, "Session expired. Please log in again.")
        |> redirect(to: ~p"/login")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end

  def sign_token(user_id) do
    Phoenix.Token.sign(ViralSpiralWeb.Endpoint, @token_salt, user_id)
  end

  defp maybe_accept_invite(nil, _user, _conn), do: :ok

  defp maybe_accept_invite(invite_token, user, _conn) do
    Invitations.accept(invite_token, user)
  end
end
