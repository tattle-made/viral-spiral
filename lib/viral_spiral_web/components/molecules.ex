defmodule ViralSpiralWeb.Molecules do
  alias ViralSpiral.Affinity
  alias ViralSpiral.Bias
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
  attr :can_use_power, :boolean, required: true

  def card(assigns) do
    ~H"""
    <div class="border-2 border-solid border-zinc-600 w-fit rounded-md bg-slate-50 flex flex-col gap-2 m-2">
      <!-- For Mobile -->
      <div class="flex-1">
        <div class="relative w-full h-80 flex flex-col gap-2">
          <div class="mt-2">
            <img class="w-full h-80 object-contain" src={card_url(@card.image)} />
          </div>
          <p class="absolute z-4 bottom-0 px-2 py-2 mx-4 text-sm/4 bg-zinc-200 bg-opacity-95 rounded-md text-xs/1">
            <%= @card.headline %>
          </p>
        </div>
      </div>

      <div class="flex flex-col py-2">
        <div class="px-2 flex flex-row gap-2 align-center">
          <span class="text-sm mb-1 self-center">Pass to</span>

          <div class="flex flex-row flex-wrap gap-2 self-center">
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
          <div :if={@can_use_power && @card.can_mark_as_fake}>
            <button
              class="py-1 px-2 hover:bg-orange-300 text-xs rounded-md border border-zinc-900"
              phx-click={
                JS.push("mark_as_fake",
                  value: %{from_id: @from, card: %{id: @card.id, veracity: @card.veracity}}
                )
              }
            >
              Mark as Fake
            </button>
          </div>
          <div :if={@can_use_power && @can_turn_fake && @card.can_turn_fake}>
            <button
              class="py-1 px-2 hover:bg-orange-300 text-xs rounded-md border border-zinc-900"
              phx-click={
                JS.push("turn_fake",
                  value: %{from_id: @from, card: %{id: @card.id, veracity: @card.veracity}}
                )
              }
            >
              Turn to Fake
            </button>
          </div>
        </div>
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

  def dp_url(player_id) do
    "https://s3.ap-south-1.amazonaws.com/media.viralspiral.net/avatar/dp_0#{:erlang.phash2(player_id, 7) + 1}.png"
  end

  def bg_class(identity) do
    case identity do
      :red -> "bg-red-500 border-red-500"
      :blue -> "bg-blue-500 border-blue-500"
      :yellow -> "bg-yellow-500 border-yellow-500"
      _ -> "bg-gray-200 border-gray-200"
    end
  end

  attr :player, :map, required: true

  def player_score_card(assigns) do
    ~H"""
    <div class="flex flex-row h-fit w-fit p-2 gap-2 border border-px-2 rounded-md bg-slate-50">
      <div class={"h-12 w-12 #{bg_class(@player.identity)} border border-2 rounded-md overflow-hidden"}>
        <img class=" h-12 w-12 object-fit" src={dp_url(@player.id)} />
      </div>

      <div>
        <div class="flex flex-row flex-wrap gap-4">
          <p><%= @player.name %></p>
          <p><%= @player.clout %></p>
        </div>
        <div class="flex flex-row gap-4">
          <div :for={{bias, value} <- @player.biases}>
            <span><%= Bias.label(bias) %></span>
            <span><%= value %></span>
          </div>
        </div>
        <div class="flex flex-row gap-4">
          <div :for={{affinity, value} <- @player.affinities}>
            <span><%= Affinity.label(affinity) %></span>
            <span><%= value %></span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :players, :list, required: true

  def carousel_score_card(assigns) do
    ~H"""
    <div class="relative w-full" data-carousel="static">
      <!-- Carousel Wrapper -->
      <div class="relative h-28 overflow-hidden md:hidden">
        <div
          :for={player <- @players}
          class="absolute block w-full h-full flex justify-center items-center md:w-56"
          data-carousel-item
        >
          <.player_score_card player={player} />
        </div>
      </div>

      <div class="md:flex md:flex-row gap-2 hidden md:block md:visible justify-center">
        <div :for={player <- @players} class="w-fit h-28 flex justify-center items-center md:w-56">
          <.player_score_card player={player} />
        </div>
      </div>

      <button
        type="button"
        class="absolute top-0 start-0 z-30 flex items-center h-full cursor-pointer md:invisible px-2"
        data-carousel-prev
      >
        <div class="h-10 w-10 p-2 bg-slate-100 hover:bg-slate-200 rounded-full inline-flex items-center justify-center">
          <.icon name="hero-arrow-left-solid" class="h-full w-full" />
        </div>
      </button>

      <button
        type="button"
        class="absolute top-0 end-0 z-30 flex items-center h-full cursor-pointer md:invisible px-2"
        data-carousel-next
      >
        <div class="h-10 w-10 p-2 bg-slate-100 hover:bg-slate-200 rounded-full inline-flex items-center justify-center">
          <.icon name="hero-arrow-right-solid" class="h-full w-full" />
        </div>
      </button>
    </div>
    """
  end
end
