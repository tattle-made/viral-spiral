defmodule ViralSpiralWeb.RoomController do
  use ViralSpiralWeb, :controller
  alias ViralSpiral.Room
  alias ViralSpiral.Room.Actions
  alias ViralSpiral.Entity.Room, as: EntityRoom

  def create(conn, %{"player_name" => player_name}) do
    room_name = EntityRoom.name()
    action = Actions.reserve_room(%{"player_name" => player_name})

    with %{name: reserved_name} <- Room.reserve(room_name, :multiplayer),
         {:ok, room_gen} <- Room.room_gen!(reserved_name),
         _state <- GenServer.call(room_gen, action) do
      json(conn, %{room_name: reserved_name})
    else
      _ ->
        conn
        |> put_status(422)
        |> json(%{error: "Could not create room"})
    end
  end
end
