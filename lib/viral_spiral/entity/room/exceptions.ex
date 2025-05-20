defmodule ViralSpiral.Entity.Room.Exceptions do
  defmodule IllegalReservation do
    defexception [:message]
  end

  defmodule JoinBeforeReserving do
    defexception message: "You are trying to join this room before reserving it"
  end
end
