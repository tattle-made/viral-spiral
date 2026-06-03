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
              <div class="bg-white border border-zinc-200 rounded-xl shadow-sm overflow-hidden">
                <div class="px-6 py-4 flex items-center justify-between border-b border-zinc-100">
                  <div>
                    <h3 class="font-semibold text-zinc-900"><%= schema.name %></h3>
                    <%= if schema.description do %>
                      <p class="text-sm text-zinc-500 mt-0.5"><%= schema.description %></p>
                    <% end %>
                  </div>
                  <.link navigate={~p"/platform/games/#{@game.id}/cards/new?schema_id=#{schema.id}"}>
                    <.button class="bg-zinc-900 hover:bg-zinc-700 text-white px-3 py-1.5 rounded-lg text-sm font-semibold">
                      + Add Card
                    </.button>
                  </.link>
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

                <%!-- Cards --%>
                <%= if schema.cards != [] do %>
                  <div class="divide-y divide-zinc-100">
                    <%= for card <- schema.cards do %>
                      <div class="px-6 py-3 flex items-center gap-4">
                        <%= if card.image_key do %>
                          <img
                            src={ViralSpiral.S3.public_url(card.image_key)}
                            class="w-12 h-12 rounded object-cover flex-shrink-0 bg-zinc-100"
                          />
                        <% else %>
                          <div class="w-12 h-12 rounded bg-zinc-100 flex-shrink-0 flex items-center justify-center">
                            <.icon name="hero-photo" class="w-5 h-5 text-zinc-300" />
                          </div>
                        <% end %>
                        <div class="flex-1 min-w-0">
                          <p class="font-medium text-zinc-900 truncate"><%= card.label %></p>
                          <p class="text-xs text-zinc-400 truncate">
                            <%= card.attributes |> Map.values() |> Enum.take(3) |> Enum.join(" · ") %>
                          </p>
                        </div>
                      </div>
                    <% end %>
                  </div>
                <% end %>
              </div>
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
