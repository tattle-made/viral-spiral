defmodule ViralSpiralWeb.Atoms do
  use ViralSpiralWeb, :html

  attr :card, :map, required: true
  attr :from, :string, required: true

  def card(assigns) do
    ~H"""
    <div class="p-2 border-2 rounded-lg bg-slate-200">
      <p><%= @card.headline %></p>
      <div class="h-3"></div>
      <span>pass to:</span>

      <div class="flex flex-row gap-x-2">
        <div :for={player <- @card.pass_to} }>
          <button
            phx-click="pass_to"
            value={
              Jason.encode!(%{
                from_id: @from,
                to_id: player.id,
                card: %{id: @card.id, veracity: @card.veracity}
              })
            }
            class=" py-1 px-2 bg-[#015058] hover:bg-[#21802B] text-white rounded"
          >
            <%= player.name %>
          </button>
        </div>
      </div>
      <div class="mt-6">
        <button
          phx-click="keep"
          value={
            Jason.encode!(%{
              from_id: @from,
              card: %{
                id: @card.id,
                veracity: @card.veracity
              }
            })
          }
          class="py-1 px-2 bg-[#015058] hover:bg-[#21802B] text-white rounded"
        >
          Keep
        </button>
      </div>
      <div class="mt-4">
        <button
          phx-click="discard"
          value={
            Jason.encode!(%{
              from_id: @from,
              card: %{
                id: @card.id,
                veracity: @card.veracity
              }
            })
          }
          class="py-1 px-2 bg-[#015058] hover:bg-[#21802B] text-white rounded"
        >
          Discard
        </button>
      </div>

      <div :if={@card.source == nil} class="mt-4">
        <button
          phx-click="view_source"
          value={
            Jason.encode!(%{
              from_id: @from,
              card: %{
                id: @card.id,
                veracity: @card.veracity
              }
            })
          }
          class="py-1 px-2 bg-[#015058] hover:bg-[#21802B] text-white rounded"
        >
          View Source
        </button>
      </div>

      <div :if={@card.source != nil} class="mt-4">
        <button
          phx-click="hide_source"
          value={
            Jason.encode!(%{
              from_id: @from,
              card: %{
                id: @card.id,
                veracity: @card.veracity
              }
            })
          }
          class="py-1 px-2 bg-[#015058] hover:bg-[#21802B] text-white rounded"
        >
          Hide Source
        </button>
      </div>

      <div :if={@card.source != nil} class="bg-zinc-100 p-2 mt-2">
        <p class="font-light text-gray-800">Author</p>
        <p class="font-normal"><%= @card.source.author %></p>
        <p class="font-light text-gray-800">Headline</p>
        <p class="font-normal"><%= @card.source.headline %></p>
        <p class="font-light text-gray-800">Content</p>
        <p class="font-normal"><%= @card.source.content %></p>
      </div>

      <div :if={@card.can_mark_as_fake} class="mt-4">
        <button
          phx-click="mark_as_fake"
          value={
            Jason.encode!(%{
              from_id: @from,
              card: %{
                id: @card.id,
                veracity: @card.veracity
              }
            })
          }
          class="py-1 px-2 bg-[#015058] hover:bg-[#21802B] text-white rounded"
        >
          Mark as fake
        </button>
      </div>
    </div>
    """
  end
end
