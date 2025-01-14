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

      <div :for={player <- @card.pass_to} }>
        <button
          phx-click="pass_to"
          value={1}
          phx-value-to={player.id}
          phx-value-from={@from}
          phx-value-card-id={@card.id}
          phx-value-card-veracity={"#{@card.veracity}"}
          class="inline"
        >
          <%= player.name %>
        </button>
      </div>
    </div>
    """
  end
end
