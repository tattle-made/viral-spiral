defmodule ViralSpiralWeb.Atoms do
  use ViralSpiralWeb, :html

  attr :card, :map, required: true

  def card(assigns) do
    ~H"""
    <div class="p-2 border-2 rounded-lg bg-slate-400">
      <p><%= @card.headline %></p>
    </div>
    """
  end
end
