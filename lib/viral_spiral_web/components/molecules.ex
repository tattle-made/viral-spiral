defmodule ViralSpiralWeb.Molecules do
  alias ViralSpiral.Affinity
  alias ViralSpiral.Bias
  use ViralSpiralWeb, :html
  import ViralSpiralWeb.CoreComponents

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
  attr :in_spec_mode, :boolean, default: false
  attr :current_turn_player_name, :string, default: nil

  def card(assigns) do
    ~H"""
    <div class="border-2 border-solid border-zinc-600 w-fit rounded-md bg-slate-50 flex flex-col gap-2 m-2">
      <!-- For Mobile -->
      <div class="flex-1">
        <p :if={@current_turn_player_name} class="text-sm ml-1">
          <strong>Turn:</strong> <%= @current_turn_player_name %>
        </p>
        <div class="relative w-full h-80 flex flex-col gap-2">
          <div class={"#{if @current_turn_player_name, do: "", else: "mt-2"}"}>
            <img class="w-full h-80 object-contain" src={card_url(@card.image)} />
          </div>
          <p
            :if={!@in_spec_mode}
            class="absolute z-4 bottom-0 px-2 py-2 mx-4 text-sm/4 bg-zinc-200 bg-opacity-95 rounded-md text-xs/1"
          >
            <%= @card.headline %>
          </p>
        </div>
      </div>

      <div class="flex flex-col py-2">
        <%= if !is_nil(@card.pass_to) and length(@card.pass_to) != 0 and !@in_spec_mode do %>
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
        <% end %>

        <div :if={!@in_spec_mode} class="mt-2 flex flex-row gap-2 flex-wrap px-2">
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
            <%= if @in_spec_mode do %>
              <!-- Spectator mode: do not send events; only open modal if source already present -->
              <button
                phx-click={show_modal("source-modal")}
                class="py-1 px-2 hover:bg-orange-300 text-xs rounded-md border border-zinc-900"
                disabled={@card.source == nil}
              >
                View Source
              </button>
            <% else %>
              <!-- Multiplayer mode: push event to fetch source, then open modal -->
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
            <% end %>
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
              Add Hate
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

  def bias_color_class(bias) do
    case Bias.label(bias) do
      "Red" -> "bg-red-dark"
      "Blue" -> "bg-blue-dark"
      "Yellow" -> "bg-yellow-dark"
      _ -> "bg-gray-400"
    end
  end

  def affinity_image_filename(affinity) do
    case Affinity.label(affinity) do
      "Cat" -> "cat"
      "Sock" -> "sock"
      "High Five" -> "high-five"
      "Houseboat" -> "boat"
      "Skub" -> "skub"
      _ -> "default"
    end
  end

  attr :player, :map, required: true

  def player_score_card(assigns) do
    ~H"""
    <div class="flex flex-row h-fit w-fit p-2 gap-6 border border-slate-100 rounded-md bg-slate-100">
      <div class="flex flex-col gap-1">
        <div class={"h-12 w-12 #{bg_class(@player.identity)} border-2 rounded-md overflow-hidden"}>
          <img class="h-12 w-12 object-fit" src={dp_url(@player.id)} />
        </div>
        <p class="text-textcolor-light font-extrabold text-lg"><%= @player.name %></p>
      </div>
      <div>
        <div class="text-textcolor-light font-extrabold text-xl flex flex-row gap-2">
          <.info_tooltip id={"clout-#{@player.id}"}>
            <span class="text-sm">Clout</span>

            <:tooltip_content>
              <h2 class="text-lg font-semibold">Clout</h2>
              <p><strong>Clout</strong> measures a <strong>Player's influence</strong>.</p>
              <p>At 10 Clout → <strong>Victory!</strong></p>
            </:tooltip_content>
          </.info_tooltip>
          <p id={"#{@player.id}-clout"} phx-hook="HookCounter">
            <%= @player.clout %>
          </p>
        </div>
        <div class="flex flex-row gap-4">
          <div class="flex flex-row items-center gap-2">
            <.info_tooltip id={"biases-info-#{@player.id}"}>
              <p class="text-sm font-semibold text-textcolor-light cursor-pointer">Biases</p>
              <:tooltip_content>
                <h2 class="text-lg font-semibold">Biases</h2>
                <p>Bias ≥ 2 → Unlocks <strong>Add HATE</strong> power</p>
                <p>Bias ≥ 4 → Unlocks <strong>Viral Spiral</strong> power</p>
              </:tooltip_content>
            </.info_tooltip>
            <%= for {bias, value} <- @player.biases do %>
              <div class={"w-8 h-8 rounded-full flex items-center justify-center text-s text-textcolor-light #{bias_color_class(bias)}"}>
                <p id={"#{@player.id}-#{bias}"} phx-hook="HookCounter"><%= value %></p>
              </div>
            <% end %>
          </div>
        </div>
        <div class="flex flex-row items-center gap-2 mt-2">
          <.info_tooltip id={"affinities-info-#{@player.id}"}>
            <p class="text-sm font-semibold text-textcolor-light cursor-pointer">Affinities</p>
            <:tooltip_content>
              <h2 class="text-lg font-semibold">Affinities</h2>
              <p>Affinity ±2 → Unlocks <strong>Cancel Player</strong> power</p>
              <p>Affinity ±4 → Unlocks <strong>Viral-Spiral</strong> power</p>
            </:tooltip_content>
          </.info_tooltip>
          <div class="flex flex-row gap-2 items-center">
            <%= for {affinity, value} <- @player.affinities do %>
              <div class="relative w-9 h-9">
                <img
                  class="w-full h-full object-contain -rotate-12"
                  src={"/images/affinity-#{affinity_image_filename(affinity)}.png"}
                  alt={Affinity.label(affinity)}
                />
                <div class="absolute -top-1 -right-1 bg-accent-1 text-neutral-3 text-s w-5 h-5 rounded-full flex items-center justify-center shadow">
                  <p id={"#{@player.id}-#{affinity}"} phx-hook="HookCounter"><%= value %></p>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :players, :list, required: true

  def carousel_score_card(assigns) do
    ~H"""
    <div
      id="carousel-score-card"
      class="relative w-full"
      data-carousel="static"
      phx-hook="CarouselHook"
    >
      <!-- Carousel Wrapper -->
      <div class="relative h-28 overflow-hidden md:hidden">
        <div
          :for={{player, index} <- Enum.with_index(@players)}
          class={"absolute inset-0 #{if index == 0, do: "translate-x-0", else: "translate-x-full"} block w-full h-full flex justify-center items-center"}
          data-carousel-item
        >
          <.player_score_card player={player} />
        </div>
      </div>

      <div class="md:flex md:flex-row gap-6 hidden md:block md:visible justify-center">
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

  @doc """
  Rulebook component that displays a rulebook inside a Carousel, wrapped in a modal.
  It is built with the modal component from core_components and UI elements from the Flowbite library.
  The parent modal uses the ID "rulebook", which can be targeted to toggle the component from any LiveView.
  """
  def rulebook(assigns) do
    ~H"""
    <.modal id="rulebook">
      <div id="controls-carousel" class="relative w-full" data-carousel="static">
        <!-- Carousel wrapper -->
        <div class="relative h-56 overflow-x-hidden rounded-lg md:h-96">
          <!-- Slide: Cover (active) -->
          <div
            class=" duration-700 ease-in-out p-6 md:p-10 flex flex-col md:flex-row items-center gap-6"
            data-carousel-item="active"
          >
            <div class="flex-1">
              <h2 class="text-2xl md:text-4xl font-extrabold">Viral Spiral — Rulebook</h2>
              <p class="mt-2 text-sm md:text-base">
                Draw news. Share opinions. Chase clout — but don’t let chaos win.
              </p>
            </div>
            <div class="w-24 md:w-32 flex-shrink-0">
              <img
                src="/images/rulebook/rulebook_cover.webp"
                alt="Cover illustration"
                class="w-full h-full object-cover shadow"
              />
            </div>
          </div>
          <!-- Slide 1 — Draw a Card -->
          <div
            class=" duration-700 ease-in-out p-6 md:p-10 flex flex-col md:flex-row items-center gap-6"
            data-carousel-item
          >
            <div class="flex-1">
              <h3 class="text-xl font-bold">1 — Draw a Card 🔍</h3>
              <p class="mt-2 text-sm">
                On your turn draw 1 card representing a news item on the internet: this could be either <strong>TOPICAL</strong>, <strong>AFFINITY</strong>, or <strong>HATE</strong>.
              </p>
            </div>
            <div class="w-28 md:w-40 flex-shrink-0">
              <img
                src="/images/rulebook/rulebook_drawcard.avif"
                alt="Draw card"
                class="w-full h-full object-cover rounded"
              />
            </div>
          </div>
          <!-- Slide 1.5 — Types of Cards -->
          <div
            class=" duration-700 ease-in-out p-6 md:p-10 flex flex-col md:flex-row items-center gap-6"
            data-carousel-item
          >
            <div class="flex-1">
              <h3 class="text-xl font-bold">1.5 — Card Types 🔍</h3>

              <img
                src="/images/rulebook/rulebook_cards_info.png"
                alt="Draw card"
                class="w-full h-full object-cover rounded"
              />
              <div class="flex justify-around items-start gap-4 text-xs">
                <p class="flex-1 min-w-0 text-center">AFFECT CLOUT</p>
                <p class="flex-1 min-w-0 text-center">AFFECT YOUR CLOUT AND CORRESPONDING AFFINITY</p>
                <p class="flex-1 min-w-0 text-center">
                  AFFECT YOUR CLOUT, BIAS AND THE CITY'S CHAOS COUNTDOWN
                </p>
              </div>
            </div>
          </div>
          <!-- Slide 2 — Check, Pass, Keep -->
          <div
            class=" duration-700 ease-in-out p-6 md:p-10 flex flex-col md:flex-row items-center gap-6"
            data-carousel-item
          >
            <div class="flex-1">
              <h3 class="text-xl font-bold">2 — Check, Pass, Keep 🔁</h3>
              <p class="mt-2 text-sm">
                Optionally check the source, then <strong>pass</strong>, <strong>discard</strong>, or <strong>keep</strong>. Each new player a card passes through gives the original sharer <strong>+1 CLOUT</strong>.
              </p>
              <p class="mt-3 text-xs text-gray-500">
                Tip: Keep cards strategically to use later for your Viral Spiral move.
              </p>
            </div>
            <div class="w-28 md:w-40 flex-shrink-0">
              <img
                src="/images/rulebook/rulebook_passcard.avif"
                alt="Pass card"
                class="w-full h-full object-cover rounded"
              />
            </div>
          </div>
          <!-- Slide 3 — Fake News -->
          <div
            class=" duration-700 ease-in-out p-6 md:p-10 flex flex-col md:flex-row items-center gap-6"
            data-carousel-item
          >
            <div class="flex-1">
              <h3 class="text-xl font-bold">3 — Fake News! ⚠️</h3>
              <p class="mt-2 text-sm">
                If the headline doesn't match the source, that news is fake! If someone passes you fake news you can mark it as such to make them <strong>lose 1 CLOUT</strong>!
              </p>
              <p class="mt-3 text-xs text-gray-500">
                Be Careful: If you wrongly mark it as fake, <span class="font-semibold">YOU</span>
                will <span class="font-semibold">lose 1 CLOUT!</span>
              </p>
            </div>
            <div class="w-28 md:w-40 flex-shrink-0">
              <img
                src="/images/rulebook/rulebook_fakenews.webp"
                alt="Fake news"
                class="w-full h-full object-cover rounded"
              />
            </div>
          </div>
          <!-- Slide 4 — Affinity & Hate Counters -->
          <div
            class=" duration-700 ease-in-out p-6 md:p-10 flex flex-col md:flex-row items-center gap-4"
            data-carousel-item
          >
            <div class="flex-1">
              <h3 class="text-xl font-bold">4 — Affinity & Hate ⚖️</h3>
              <p class="mt-2 text-sm">
                Sharing <strong>AFFINITY</strong>
                or <strong>HATE</strong>
                increases their counters. Once you pass any of these cards you must continue sharing similar cards or <strong>lose 1 CLOUT</strong>.
              </p>
              <p class="mt-3 text-xs text-gray-500">
                A sample player profile from the game. They belong to the red community (A), have a clout point (B) of 4 and anti-yellow and anti-blue biases (C) of 2 and 5, respectively. They have an affinity of +1 for skub (D) and -2 for houseboats (E).
              </p>
            </div>
            <div class="w-52 md:w-64 flex-shrink-0">
              <img
                src="/images/rulebook/rulebook_playerprofile_vector.png"
                alt="Counters"
                class="w-full object-cover rounded"
              />
            </div>
          </div>
          <!-- Slide 5 — Chaos Meter -->
          <div
            class=" duration-700 ease-in-out p-6 md:p-10 flex flex-col md:flex-row items-center gap-6"
            data-carousel-item
          >
            <div class="flex-1">
              <h3 class="text-xl font-bold">5 — Chaos Meter ⏳</h3>
              <p class="mt-2 text-sm">
                Sharing HATE moves the global <strong>CHAOS</strong>
                counter down from <strong>10 → 0</strong>. If CHAOS hits <strong>0</strong>, the game ends and <strong>everyone loses</strong>!
              </p>
              <p class="mt-3 text-xs text-gray-500">
                Endgame Rule: If a player reaches 10 CLOUT at the same time the CHAOS meter hits 0, the game ends and all players lose.
              </p>
            </div>
            <div class="w-28  md:w-40  flex-shrink-0">
              <img
                src="/images/rulebook/rulebook_chaos.webp"
                alt="Chaos meter"
                class="w-full h-full object-cover rounded"
              />
            </div>
          </div>
          <!-- Slide 6 — Powers: Cancel & Manufacture -->
          <div
            class=" duration-700 ease-in-out p-6 md:p-10 flex flex-col md:flex-row items-center gap-6"
            data-carousel-item
          >
            <div class="flex-1">
              <h3 class="text-xl font-bold">6 — Powers ⚡️</h3>
              <p class="mt-2 text-sm">
                Reach <strong>±2 Affinity</strong>
                → you can <strong>CANCEL</strong>
                another player, if same-affinity allies vote for it. <br /> <br /> Reach
                <strong>±2 HATE</strong>
                → you can <strong>Add HATE</strong>
                to a card before passing it.
              </p>
            </div>
            <div class="w-28 md:w-40 flex-shrink-0">
              <img
                src="/images/rulebook/rulebook_powers.avif"
                alt="Powers"
                class="w-full h-full object-cover rounded"
              />
            </div>
          </div>
          <!-- Slide 7 — Viral Spiral -->
          <div
            class=" duration-700 ease-in-out p-6 md:p-10 flex flex-col md:flex-row items-center gap-6"
            data-carousel-item
          >
            <div class="flex-1">
              <h3 class="text-xl font-bold">7 — Viral Spiral 🌪️</h3>
              <p class="mt-2 text-sm">
                Reach <strong>±4</strong>
                on affinity or hate → trigger <strong>VIRAL SPIRAL</strong>: share one unique card from your hand to
                <strong>every player</strong>
                in the same turn.
              </p>
              <p class="mt-3 text-xs text-gray-500">
                Tip: Used at the right time, could be game-ending.
              </p>
            </div>
            <div class="w-32 md:w-40  flex-shrink-0">
              <img
                src="/images/logo.png"
                alt="Viral Spiral"
                class="w-full h-full object-cover rounded"
              />
            </div>
          </div>
          <!-- Slide 8 — Victory -->
          <div
            class=" duration-700 ease-in-out p-6 md:p-10 flex flex-col md:flex-row items-center gap-6"
            data-carousel-item
          >
            <div class="flex-1">
              <h3 class="text-xl font-bold">8 — Winning the Game 🏆</h3>
              <p class="mt-2 text-sm">
                First player to hit <strong>10 CLOUT</strong>
                wins — provided CHAOS hasn’t reached <strong>0</strong>.
              </p>
              <p class="mt-3 text-xs text-gray-500">
                Reminder: Chase Clout, but watch the Chaos Countdown!
              </p>
            </div>
            <div class="w-28 md:w-40 flex-shrink-0">
              <img
                src="/images/rulebook/rulebook_victory.avif"
                alt="Victory"
                class="w-full h-full object-cover rounded"
              />
            </div>
          </div>
        </div>
        <!-- Slider indicators -->
        <div class="  flex  space-x-3  justify-center ">
          <button
            type="button"
            class="w-3 h-3 rounded-full"
            aria-current="true"
            aria-label="Slide 1"
            data-carousel-slide-to="0"
          >
          </button>
          <button
            type="button"
            class="w-3 h-3 rounded-full"
            aria-current="false"
            aria-label="Slide 2"
            data-carousel-slide-to="1"
          >
          </button>
          <button
            type="button"
            class="w-3 h-3 rounded-full"
            aria-current="false"
            aria-label="Slide 3"
            data-carousel-slide-to="2"
          >
          </button>
          <button
            type="button"
            class="w-3 h-3 rounded-full"
            aria-current="false"
            aria-label="Slide 4"
            data-carousel-slide-to="3"
          >
          </button>
          <button
            type="button"
            class="w-3 h-3 rounded-full"
            aria-current="false"
            aria-label="Slide 5"
            data-carousel-slide-to="4"
          >
          </button>
          <button
            type="button"
            class="w-3 h-3 rounded-full"
            aria-current="false"
            aria-label="Slide 6"
            data-carousel-slide-to="5"
          >
          </button>
          <button
            type="button"
            class="w-3 h-3 rounded-full"
            aria-current="false"
            aria-label="Slide 7"
            data-carousel-slide-to="6"
          >
          </button>
          <button
            type="button"
            class="w-3 h-3 rounded-full"
            aria-current="false"
            aria-label="Slide 8"
            data-carousel-slide-to="7"
          >
          </button>
          <button
            type="button"
            class="w-3 h-3 rounded-full"
            aria-current="false"
            aria-label="Slide 9"
            data-carousel-slide-to="8"
          >
          </button>
          <button
            type="button"
            class="w-3 h-3 rounded-full"
            aria-current="false"
            aria-label="Slide 10"
            data-carousel-slide-to="9"
          >
          </button>
        </div>
        <!-- Slider controls -->
        <div class="flex justify-center gap-5 mt-4">
          <button
            type="button"
            class=" z-30 flex items-center justify-center h-full px-4 cursor-pointer group focus:outline-none"
            data-carousel-prev
          >
            <span class="inline-flex items-center justify-center w-10 h-10 rounded-full bg-white/30 dark:bg-gray-800/30 group-hover:bg-white/50 dark:group-hover:bg-gray-800/60 group-focus:ring-4 group-focus:ring-white dark:group-focus:ring-gray-800/70 group-focus:outline-none">
              <svg
                class="w-4 h-4 text-white dark:text-gray-800 rtl:rotate-180"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 6 10"
              >
                <path
                  stroke="currentColor"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M5 1 1 5l4 4"
                />
              </svg>
              <span class="sr-only">Previous</span>
            </span>
          </button>

          <button
            type="button"
            class="z-30 flex items-center justify-center h-full px-4 cursor-pointer group focus:outline-none"
            data-carousel-next
          >
            <span class="inline-flex items-center justify-center w-10 h-10 rounded-full bg-white/30 dark:bg-gray-800/30 group-hover:bg-white/50 dark:group-hover:bg-gray-800/60 group-focus:ring-4 group-focus:ring-white dark:group-focus:ring-gray-800/70 group-focus:outline-none">
              <svg
                class="w-4 h-4 text-white dark:text-gray-800 rtl:rotate-180"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 6 10"
              >
                <path
                  stroke="currentColor"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="m1 9 4-4-4-4"
                />
              </svg>
              <span class="sr-only">Next</span>
            </span>
          </button>
        </div>
      </div>
    </.modal>
    """
  end
end
