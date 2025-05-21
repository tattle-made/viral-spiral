defmodule ViralSpiral.Room.Action do
  alias ViralSpiral.Room.Actions.Player.{
    ReserveRoom,
    JoinRoom,
    StartGame,
    KeepCard,
    PassCard,
    DiscardCard,
    MarkAsFake,
    ViewSource,
    CancelPlayerInitiate,
    CancelPlayerVote
  }

  alias ViralSpiral.Room.Actions.Engine.{DrawCard}

  @doc """
  Actions initiated by players or game engine.

  to affect change to game state
  """

  defstruct type: nil, payload: nil

  @type action_payloads ::
          ReserveRoom.t()
          | JoinRoom.t()
          | StartGame.t()
          | KeepCard.t()
          | PassCard.t()
          | DiscardCard.t()
          | MarkAsFake.t()
          | ViewSource.t()
          | CancelPlayerInitiate.t()
          | CancelPlayerVote.t()
          | DrawCard.t()

  @type action_types :: :reserve_room | :join_room | :start_game | :draw_card

  @type t :: %{
          type: action_types(),
          payload: action_payloads()
        }
end
