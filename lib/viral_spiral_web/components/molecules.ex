defmodule ViralSpiralWeb.Molecules do
  use ViralSpiralWeb, :html

  defp card_url(file_name) do
    # Because of a mistake made by designers, all filenames have a space in it
    # when uploaded to aws s3, that space is replaced with a + sign.
    # this is a temporary fix
    # todo : fix filenames
    filename = file_name |> String.replace(" ", "+")
    file_url = "https://s3.ap-south-1.amazonaws.com/media.viralspiral.net/" <> filename
    file_url
  end

  attr :card, :map, required: true
  attr :from, :string, required: true

  def card(assigns) do
    ~H"""
    <div class="border-2 border-solid border-zinc-600 w-48 rounded-md">
      <div class="relative w-full">
        <div class="p-2">
          <img src={card_url(@card.image)} />
        </div>
        <p class="absolute mx-2 z-4 bottom-2 p-2 text-sm/4 bg-zinc-200 bg-opacity-75 rounded-sm">
          <%= @card.headline %>
        </p>
      </div>
      <div class="border border-dashed border-zinc-400 mb" />
      <div class="px-2">
        <span class="text-sm mb-1">Pass to</span>

        <div class="flex flex-row flex-wrap gap-2">
          <div :for={player <- @card.pass_to} }>
            <button
              phx-click={
                JS.push("pass_to",
                  value: %{
                    from_id: @from,
                    to_id: player.id,
                    card: %{id: @card.id, veracity: @card.veracity}
                  }
                )
              }
              class=" py-1 px-2 hover:bg-orange-300 text-xs rounded-md border border-zinc-900"
            >
              <%= player.name %>
            </button>
          </div>
        </div>
      </div>

      <div class="border border-dashed border-zinc-400 mt-2 mb-2" />

      <div class="mt-2 flex flex-row gap-2 flex-wrap px-2">
        <div class="">
          <button
            phx-click={
              JS.push("keep",
                value: %{
                  from_id: @from,
                  card: %{id: @card.id, veracity: @card.veracity}
                }
              )
            }
            class="py-1 px-2 hover:bg-orange-300 text-xs rounded-md border border-zinc-900"
          >
            Keep
          </button>
        </div>
        <div>
          <button
            phx-click={
              JS.push("discard",
                value: %{
                  from_id: @from,
                  card: %{id: @card.id, veracity: @card.veracity}
                }
              )
            }
            class="py-1 px-2 hover:bg-orange-300 text-xs rounded-md border border-zinc-900"
          >
            Discard
          </button>
        </div>
      </div>

      <div class="border border-dashed border-zinc-400 mt-2 mb-2" />

      <div class="flex flex-row flex-wrap gap-2 px-2">
        <div class="">
          <button
            phx-click={
              JS.push("view_source",
                value: %{from_id: @from, card: %{id: @card.id, veracity: @card.veracity}}
              )
              |> show_modal("source-modal")
            }
            class="py-1 px-2 hover:bg-orange-300 text-xs rounded-md border border-zinc-900"
            disabled={@card.source != nil}
          >
            View Source
          </button>
        </div>
        <button class="py-1 px-2 hover:bg-orange-300 text-xs rounded-md border border-zinc-900">
          Mark as Fake
        </button>
        <button class="py-1 px-2 hover:bg-orange-300 text-xs rounded-md border border-zinc-900">
          Turn to Fake
        </button>
      </div>

      <.modal
        id="source-modal"
        on_cancel={
          JS.push("hide_source",
            value: %{from_id: @from, card: %{id: @card.id, veracity: @card.veracity}}
          )
        }
      >
        <div :if={@card.source != nil} class="bg-zinc-100 p-2 mt-2">
          <p class="font-light text-gray-800">Author</p>
          <p class="font-normal"><%= @card.source.author %></p>
          <p class="font-light text-gray-800">Headline</p>
          <p class="font-normal"><%= @card.source.headline %></p>
          <p class="font-light text-gray-800">Content</p>
          <p class="font-normal"><%= @card.source.content %></p>
        </div>
      </.modal>

      <div class="mb-2" />
    </div>
    """
  end

  def hand_card(assigns) do
    ~H"""
    <div>
      <img src={card_url(@card.image)} />
    </div>
    """
  end

  def card_preview(assigns) do
    ~H"""
    <div class="border-2 border-solid border-zinc-600 w-48 rounded-md">
      <div class="relative w-full">
        <div class="p-2">
          <img src={card_url(@card.image)} />
        </div>
        <p class="absolute mx-2 z-4 bottom-2 p-2 text-sm/4 bg-zinc-200 bg-opacity-75 rounded-sm">
          <%= @card.headline %>
        </p>
      </div>
    </div>
    """
  end
end
