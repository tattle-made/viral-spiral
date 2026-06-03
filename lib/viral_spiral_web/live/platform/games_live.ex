defmodule ViralSpiralWeb.Platform.GamesLive do
  use ViralSpiralWeb, :live_view

  alias ViralSpiral.Platform
  alias ViralSpiral.Platform.Game
  alias ViralSpiralWeb.UserAuth

  on_mount {UserAuth, :require_authenticated}

  def render(assigns) do
    ~H"""
    <div class="max-w-5xl mx-auto px-4 py-10">
      <.header>
        My Games
        <:subtitle>Games you own or collaborate on.</:subtitle>
        <:actions>
          <.link patch={~p"/platform/games/new"}>
            <.button class="bg-fuchsia-700 hover:bg-fuchsia-900 text-white px-4 py-2 rounded-lg font-semibold">
              New Game
            </.button>
          </.link>
        </:actions>
      </.header>

      <div class="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <%= for game <- @games do %>
          <.link navigate={~p"/platform/games/#{game.id}"} class="block group">
            <div class="bg-white border border-zinc-200 rounded-xl p-6 shadow-sm hover:shadow-md hover:border-fuchsia-300 transition-all">
              <h2 class="text-lg font-semibold text-zinc-900 group-hover:text-fuchsia-700 transition-colors">
                <%= game.name %>
              </h2>
              <%= if game.description do %>
                <p class="mt-1 text-sm text-zinc-500 line-clamp-2"><%= game.description %></p>
              <% end %>
              <p class="mt-4 text-xs text-zinc-400">
                Created <%= Calendar.strftime(game.inserted_at, "%b %d, %Y") %>
              </p>
            </div>
          </.link>
        <% end %>

        <%= if @games == [] do %>
          <div class="col-span-full text-center py-16 text-zinc-400">
            <p class="text-lg">No games yet.</p>
            <p class="text-sm mt-1">Create your first game to get started.</p>
          </div>
        <% end %>
      </div>
    </div>

    <.modal :if={@live_action == :new} id="new-game-modal" show on_cancel={JS.patch(~p"/platform/games")}>
      <div class="p-2">
        <h2 class="text-xl font-bold text-zinc-900 mb-6">Create a game</h2>
        <.simple_form for={@form} phx-submit="create_game" phx-change="validate_game">
          <.input field={@form[:name]} label="Game name" placeholder="e.g. Viral Spiral" />
          <.input field={@form[:description]} type="textarea" label="Description" placeholder="What is this game about?" />
          <:actions>
            <.button
              class="bg-fuchsia-700 hover:bg-fuchsia-900 text-white px-4 py-2 rounded-lg font-semibold"
              phx-disable-with="Creating..."
            >
              Create game
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </.modal>
    """
  end

  def mount(_params, _session, socket) do
    games = Platform.list_games_for_user(socket.assigns.current_user.id)
    changeset = Game.changeset(%Game{}, %{})

    {:ok,
     assign(socket,
       games: games,
       form: to_form(changeset),
       page_title: "My Games"
     )}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("validate_game", %{"game" => params}, socket) do
    changeset =
      %Game{}
      |> Game.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("create_game", %{"game" => params}, socket) do
    user = socket.assigns.current_user
    attrs = Map.put(params, "created_by", user.id)

    case Platform.create_game(attrs) do
      {:ok, game} ->
        {:noreply, push_navigate(socket, to: ~p"/platform/games/#{game.id}")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
