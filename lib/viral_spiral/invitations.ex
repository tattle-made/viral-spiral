defmodule ViralSpiral.Invitations do
  @moduledoc """
  Handles inviting users to games as collaborators or playtesters.

  Flow:
    - If invitee already has an account: create GameMembership directly + send notification.
    - If not: create a pending Invite with a token + send signup email with the token link.
    - When the new user signs up via the invite link, call accept/2 to redeem the token.
  """

  import Ecto.Query
  alias ViralSpiral.Repo
  alias ViralSpiral.Accounts
  alias ViralSpiral.Emails
  alias ViralSpiral.Platform.{GameMembership, Invite, Game}

  @invite_ttl_days 7

  @doc """
  Invite `email` to `game` with the given `role` (:collaborator | :playtester).
  `invited_by` is the %User{} performing the invite.
  `base_url` is used to build links in emails (e.g. "https://viralspiral.net").
  """
  def invite(%Game{} = game, role, email, invited_by, base_url) do
    email = String.downcase(email)

    case Accounts.get_user_by_email(email) do
      nil -> invite_new_user(game, role, email, invited_by, base_url)
      user -> invite_existing_user(game, role, user, invited_by, base_url)
    end
  end

  @doc """
  Redeem an invite token after a user has signed up or logged in.
  Creates the GameMembership and marks the invite accepted.
  """
  def accept(token, user) do
    with {:ok, invite} <- fetch_valid_invite(token),
         {:ok, _membership} <- create_membership(invite.game_id, user.id, invite.role, invite.invited_by),
         {:ok, _invite} <- Repo.update(Invite.accept_changeset(invite)) do
      {:ok, invite}
    end
  end

  @doc "Return a pending (unaccepted, unexpired) invite by token, preloading the game."
  def get_pending_invite(token) do
    case fetch_valid_invite(token) do
      {:ok, invite} -> Repo.preload(invite, :game)
      error -> error
    end
  end

  defp invite_new_user(game, role, email, invited_by, base_url) do
    expires_at = DateTime.utc_now() |> DateTime.add(@invite_ttl_days * 86_400) |> DateTime.truncate(:second)

    attrs = %{
      email: email,
      role: role,
      game_id: game.id,
      invited_by: invited_by.id,
      expires_at: expires_at
    }

    case %Invite{} |> Invite.changeset(attrs) |> Repo.insert() do
      {:ok, invite} ->
        Emails.invite_new_user(email, game.name, role, invite.token, base_url)
        {:ok, :invite_sent}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp invite_existing_user(game, role, user, invited_by, base_url) do
    case create_membership(game.id, user.id, role, invited_by.id) do
      {:ok, membership} ->
        Emails.notify_existing_user(user.email, game.name, role, base_url)
        {:ok, membership}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp create_membership(game_id, user_id, role, invited_by_id) do
    %GameMembership{}
    |> GameMembership.changeset(%{
      game_id: game_id,
      user_id: user_id,
      role: role,
      invited_by: invited_by_id
    })
    |> Repo.insert()
  end

  defp fetch_valid_invite(token) do
    invite = Repo.get_by(Invite, token: token)

    cond do
      is_nil(invite) -> {:error, :not_found}
      Invite.accepted?(invite) -> {:error, :already_accepted}
      Invite.expired?(invite) -> {:error, :expired}
      true -> {:ok, invite}
    end
  end
end
