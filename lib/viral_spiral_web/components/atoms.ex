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
      <div class="mt-4">
        <button
          phx-click="keep"
          phx-value-from={@from}
          phx-value-card-id={@card.id}
          phx-value-card-veracity={"#{@card.veracity}"}
          class="py-1 px-2 bg-[#015058] hover:bg-[#21802B] text-white rounded"
        >
          Keep
        </button>
      </div>
    </div>
    """
  end
end
