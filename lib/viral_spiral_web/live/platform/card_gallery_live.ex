defmodule ViralSpiralWeb.Platform.CardGalleryLive do
  use ViralSpiralWeb, :live_view

  alias ViralSpiral.{Platform}
  alias ViralSpiralWeb.UserAuth

  on_mount {UserAuth, :require_authenticated}

  def render(assigns) do
    ~H"""
    <div class="max-w-5xl mx-auto px-4 py-10">
      <.back navigate={~p"/platform/games/#{@game.id}"}>
        <%= @game.name %>
      </.back>

      <div class="mt-6 flex items-start justify-between">
        <div>
          <h1 class="text-2xl font-bold text-zinc-900"><%= @schema.name %></h1>
          <%= if @schema.description do %>
            <p class="mt-1 text-zinc-500"><%= @schema.description %></p>
          <% end %>
        </div>
      </div>

      <div class="mt-8 grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
        <%!-- First item: Add new card placeholder --%>
        <.link navigate={~p"/platform/games/#{@game.id}/cards/new?schema_id=#{@schema.id}"}>
          <div class="aspect-[3/4] rounded-xl border-2 border-dashed border-zinc-300 flex flex-col items-center justify-center hover:border-fuchsia-400 hover:bg-fuchsia-50 transition-colors cursor-pointer group">
            <.icon name="hero-plus" class="w-8 h-8 text-zinc-300 group-hover:text-fuchsia-400 transition-colors" />
            <p class="mt-2 text-xs font-medium text-zinc-400 group-hover:text-fuchsia-500 transition-colors">
              Add card
            </p>
          </div>
        </.link>

        <%!-- Existing cards --%>
        <%= for card <- @cards do %>
          <div class="aspect-[3/4] rounded-xl border border-zinc-200 overflow-hidden bg-white shadow-sm relative">
            <%= if card.image_key do %>
              <img
                src={ViralSpiral.S3.public_url(card.image_key)}
                class="w-full h-full object-cover"
              />
              <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/60 to-transparent px-2 py-2">
                <p class="text-xs font-medium text-white truncate"><%= card.label %></p>
              </div>
            <% else %>
              <div class="w-full h-full flex flex-col items-center justify-center bg-zinc-50 p-3">
                <.icon name="hero-photo" class="w-8 h-8 text-zinc-300 mb-2" />
                <p class="text-xs font-medium text-zinc-700 text-center leading-tight"><%= card.label %></p>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(%{"id" => game_id, "schema_id" => schema_id}, _session, socket) do
    game = Platform.get_game!(game_id)
    schema = Platform.get_card_schema!(schema_id)
    cards = Platform.list_cards(schema_id)

    {:ok,
     assign(socket,
       game: game,
       schema: schema,
       cards: cards,
       page_title: "#{schema.name} — Cards"
     )}
  end
end
