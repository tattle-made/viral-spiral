defmodule ViralSpiralWeb.Atoms do
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
  attr :can_turn_fake, :boolean, required: true

  def card(assigns) do
    ~H"""
    <div class="p-2 border-2 rounded-lg bg-slate-200">
      <div class="flex flex-row gap-2">
        <div class="relative w-1/3 h-auto">
          <p class="absolute z-4  bottom-0 p-4 text-sm/4 bg-gray-50 bg-opacity-75 rounded-sm">
            <%= @card.headline %>
          </p>
          <div class="">
            <img src={card_url(@card.image)} />
          </div>
        </div>
        <div class="mt-1 flex gap-2 h-fit">
          <span class="px-2 py-1 bg-red-200 rounded-md text-xs text-zinc-600"><%= @card.type %></span>
          <span class="px-2 py-1 bg-red-200 rounded-md text-xs text-zinc-600">
            <%= @card.veracity %>
          </span>
          <span :if={Map.get(@card, :target, nil)} class="px-2 py-1 bg-red-200 rounded-md">
            <%= Map.get(@card, :target, "") %>
          </span>
        </div>
      </div>
      <div class="h-3"></div>
      <div class="flex flex-row gap-4">
        <span>Pass to:</span>

        <div class="flex flex-row gap-2">
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
      </div>
      <div class="mt-2 flex flex-row gap-2">
        <div class="">
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
        <div>
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
      </div>

      <div :if={@card.source == nil} class="mt-4">
        <button
          phx-click={
            JS.push("view_source",
              value: %{from_id: @from, card: %{id: @card.id, veracity: @card.veracity}}
            )
            |> show_modal("source-modal")
          }
          class="py-1 px-2 bg-[#015058] hover:bg-[#21802B] text-white rounded"
        >
          View Source
        </button>
      </div>

      <div :if={@card.source != nil} class="mt-4">
        <button
          phx-click={
            JS.push("hide_source",
              value: %{from_id: @from, card: %{id: @card.id, veracity: @card.veracity}}
            )
          }
          class="py-1 px-2 bg-[#015058] hover:bg-[#21802B] text-white rounded"
        >
          Hide Source
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

      <div :if={@card.can_turn_fake && @can_turn_fake} class="mt-4">
        <button
          phx-click="turn_fake"
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
          Turn Fake
        </button>
      </div>
    </div>
    """
  end

  attr :card, :map, required: true

  def hand_card(assigns) do
    ~H"""
    <div>
      <img src={card_url(@card.image)} />
    </div>
    """
  end

  attr :id, :string, required: true
  attr :image_name, :string, required: true

  @doc """
  Renders a new image while transitioninig smoothly from the already displayed image.

  ## Examples
    <.background id={"container-bg"} image_name={@image_id} />
  """

  def background(assigns) do
    ~H"""
    <div class="w-full h-full bg-red-400">
      <div
        id={@id}
        data-image-id={@image_name}
        class="relative bg-red-200"
        phx-hook="BackgroundHook"
        phx-update="ignore"
      >
        <img id="container-bg-stage" class="absolute w-full w-full  object-cover opacity-0" />
        <img id="container-bg-backstage" class="absolute w-full w-full  object-cover opacity-0" />
      </div>
    </div>
    """
  end
end
