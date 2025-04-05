defmodule ViralSpiral.Entity.Player.Exceptions do
  defmodule DuplicateActiveCardException do
    defexception message: "This card is already held by the player"
  end

  defmodule ActiveCardDoesNotExist do
    defexception message: "This card is not an active card for this player "
  end
end
