defmodule ViralSpiralWeb.Platform.GameDetailLive do
  use ViralSpiralWeb, :live_view

  alias ViralSpiral.{Platform, Repo}
  alias ViralSpiralWeb.UserAuth

  on_mount {UserAuth, :require_authenticated}

  def render(assigns) do
    ~H"""
    <div class="max-w-5xl mx-auto px-4 py-10">
      <.back navigate={~p"/platform/games"}>All games</.back>

      <div class="mt-6 flex items-start justify-between">
        <div>
          <h1 class="text-3xl font-bold text-zinc-900"><%= @game.name %></h1>
          <%= if @game.description do %>
            <p class="mt-1 text-zinc-500"><%= @game.description %></p>
          <% end %>
        </div>
      </div>

      <%!-- Card Schemas section --%>
      <div class="mt-10">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-xl font-semibold text-zinc-900">Card Schemas</h2>
          <.link navigate={~p"/platform/games/#{@game.id}/schemas/new"}>
            <.button class="bg-fuchsia-700 hover:bg-fuchsia-900 text-white px-3 py-1.5 rounded-lg text-sm font-semibold">
              + Add Schema
            </.button>
          </.link>
        </div>

        <%= if @schemas == [] do %>
          <div class="border border-dashed border-zinc-300 rounded-xl p-8 text-center text-zinc-400">
            <p>No card schemas yet. A schema defines what fields your cards have.</p>
          </div>
        <% else %>
          <div class="space-y-6">
            <%= for schema <- @schemas do %>
              <.link navigate={~p"/platform/games/#{@game.id}/schemas/#{schema.id}/cards"} class="block group">
                <div class="bg-white border border-zinc-200 rounded-xl shadow-sm overflow-hidden group-hover:border-zinc-300 group-hover:shadow-md transition-all">
                  <div class="px-6 py-4 flex items-center justify-between border-b border-zinc-100">
                    <div>
                      <h3 class="font-semibold text-zinc-900"><%= schema.name %></h3>
                      <%= if schema.description do %>
                        <p class="text-sm text-zinc-500 mt-0.5"><%= schema.description %></p>
                      <% end %>
                    </div>
                    <.icon name="hero-chevron-right" class="w-5 h-5 text-zinc-300 group-hover:text-zinc-500 flex-shrink-0 transition-colors" />
                  </div>

                  <%!-- Field definitions --%>
                  <div class="px-6 py-3 bg-zinc-50">
                    <p class="text-xs font-semibold text-zinc-400 uppercase tracking-wide mb-2">Fields</p>
                    <div class="flex flex-wrap gap-2">
                      <%= for field <- schema.field_definitions do %>
                        <span class="inline-flex items-center gap-1 bg-white border border-zinc-200 rounded-full px-3 py-0.5 text-xs text-zinc-700">
                          <span class="font-medium"><%= field.name %></span>
                          <span class="text-zinc-400"><%= field.type %></span>
                          <%= if field.required do %>
                            <span class="text-fuchsia-600 font-bold">*</span>
                          <% end %>
                        </span>
                      <% end %>
                    </div>
                  </div>

                  <%!-- Card count --%>
                  <div class="px-6 py-4">
                    <%= if schema.cards == [] do %>
                      <p class="text-sm text-zinc-400">No cards yet — click to add</p>
                    <% else %>
                      <span class="inline-flex items-center gap-1.5 text-sm font-medium text-zinc-600">
                        <.icon name="hero-squares-2x2-mini" class="w-4 h-4" />
                        <%= length(schema.cards) %> <%= if length(schema.cards) == 1, do: "card", else: "cards" %>
                      </span>
                    <% end %>
                  </div>
                </div>
              </.link>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(%{"id" => game_id}, _session, socket) do
    game = Platform.get_game!(game_id)

    schemas =
      Platform.list_card_schemas(game_id)
      |> Repo.preload([:field_definitions, :cards])

    {:ok,
     assign(socket,
       game: game,
       schemas: schemas,
       page_title: game.name
     )}
  end
end
