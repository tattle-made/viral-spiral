defmodule ViralSpiral.Authorization do
  @moduledoc """
  Pure policy module for game-level access control.

  Roles (per game):
    :owner        — full control, including destructive actions
    :collaborator — can manage content, cannot delete game or invite collaborators
    :playtester   — read-only access to playtest the game

  Usage:
    membership = Platform.get_membership(user, game)
    role = membership && membership.role
    Authorization.can?(role, :delete_game)  # => false
  """

  @type role :: :owner | :collaborator | :playtester | nil
  @type action ::
          :view_game
          | :manage_cards
          | :manage_card_schemas
          | :delete_game
          | :invite_collaborator
          | :invite_playtester
          | :playtest

  @spec can?(role(), action()) :: boolean()

  # Owner can do everything
  def can?(:owner, _action), do: true

  # Collaborator: everything except destructive game actions and inviting collaborators
  def can?(:collaborator, :delete_game), do: false
  def can?(:collaborator, :invite_collaborator), do: false
  def can?(:collaborator, _action), do: true

  # Playtester: can only view and play
  def can?(:playtester, :view_game), do: true
  def can?(:playtester, :playtest), do: true
  def can?(:playtester, _action), do: false

  # No membership
  def can?(nil, _action), do: false
end
