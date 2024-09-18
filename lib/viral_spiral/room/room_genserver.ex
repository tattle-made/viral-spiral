defmodule ViralSpiral.Room.RoomGenserver do
  use GenServer

  @impl true
  def init(init_arg) do
    {:ok, root}
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
end
