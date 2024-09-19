defmodule ViralSpiral.Room.GameEngine do
  alias ViralSpiral.Room.State.Root
  alias ViralSpiral.Room.State.Room
  use GenServer

  @registry ViralSpiral.Room.Registry

  def start_link(path) do
    GenServer.start_link(__MODULE__, path, name: {:via, Registry, {@registry, path}})
  end

  @impl true
  def init(_init_arg) do
    # room = Room.new() |> Room.start(4)
    # # root = Root.new(room, init_arg.players)
    # root = Root.new(room, ["adhiraj", "krys", "aman", "farah"])

    {:ok, [1]}
  end

  @impl true
  def handle_cast({:join, player_name}, state) do
  end

  @impl true
  def handle_cast({:pass, from, to}, state) do
  end

  @impl true
  def handle_cast({:keep, from}, state) do
  end

  @impl true
  def handle_cast({:discard, from}, state) do
  end

  @impl true
  def handle_cast({:check_source, from}, state) do
  end

  @impl true
  def handle_cast({:cancel, from, target}, state) do
  end

  @impl true
  def handle_cast({:viral_spiral, from, targets}, state) do
  end

  @impl true
  def handle_info(msg, state) do
    IO.inspect("msg in genserver #{msg}")
    {:noreply, state}
  end
end
