defmodule Mix.Tasks.Benchmark.State do
  alias ViralSpiral.Room.State
  alias ViralSpiral.Entity.Room
  use Mix.Task

  def run(command_line_args) do
    IO.inspect("hello")

    room =
      Room.skeleton()
      |> Room.join("adhiraj")
      |> Room.set_state(:reserved)
      |> Room.join("aman")
      |> Room.join("farah")
      |> Room.join("krys")
      |> Room.start()

    state = %State{room: room}

    Benchee.run(
      %{
        state: fn -> State.setup(state) end
      },
      time: 10,
      memory_time: 2
    )
  end
end
