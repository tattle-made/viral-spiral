defmodule ViralSpiralWeb.Platform.CardSchemaNewLive do
  use ViralSpiralWeb, :live_view

  alias ViralSpiral.Platform
  alias ViralSpiralWeb.UserAuth

  on_mount {UserAuth, :require_authenticated}

  @field_types ~w(string integer boolean enum)
  @empty_field %{tmp_id: nil, name: "", type: "string", required: false, default_value: "", enum_values: ""}

  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto px-4 py-10">
      <.back navigate={~p"/platform/games/#{@game.id}"}>
        <%= @game.name %>
      </.back>

      <h1 class="mt-6 text-2xl font-bold text-zinc-900">New Card Schema</h1>
      <p class="mt-1 text-sm text-zinc-500">
        A schema defines the structure of a card type in your game.
      </p>

      <div class="mt-8 bg-white border border-zinc-200 rounded-xl shadow-sm p-6">
        <.simple_form for={@form} phx-submit="save" phx-change="validate">
          <.input field={@form[:name]} label="Schema name" placeholder="e.g. Affinity Card, News Card" />
          <.input field={@form[:description]} type="textarea" label="Description (optional)" placeholder="What kind of cards use this schema?" />
        </.simple_form>

        <%!-- Field definitions --%>
        <div class="mt-8">
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-base font-semibold text-zinc-900">Fields</h2>
            <button
              type="button"
              phx-click="add_field"
              class="text-sm text-fuchsia-700 hover:text-fuchsia-900 font-semibold"
            >
              + Add field
            </button>
          </div>

          <%= if @fields == [] do %>
            <p class="text-sm text-zinc-400 text-center py-6 border border-dashed border-zinc-200 rounded-lg">
              No fields yet. Add fields to define what information each card stores.
            </p>
          <% else %>
            <div class="space-y-4">
              <%= for {field, idx} <- Enum.with_index(@fields) do %>
                <div class="border border-zinc-200 rounded-lg p-4 bg-zinc-50">
                  <div class="flex items-start gap-3">
                    <div class="flex-1 grid grid-cols-2 gap-3">
                      <div>
                        <label class="block text-sm font-semibold text-zinc-800 mb-1">Field name</label>
                        <input
                          type="text"
                          value={field.name}
                          placeholder="e.g. headline"
                          phx-change="update_field"
                          phx-value-idx={idx}
                          phx-value-key="name"
                          class="w-full rounded-lg border border-zinc-300 text-zinc-900 text-sm px-3 py-2 focus:outline-none focus:ring-1 focus:ring-fuchsia-500"
                        />
                      </div>
                      <div>
                        <label class="block text-sm font-semibold text-zinc-800 mb-1">Type</label>
                        <select
                          phx-change="update_field"
                          phx-value-idx={idx}
                          phx-value-key="type"
                          class="w-full rounded-lg border border-zinc-300 text-zinc-900 text-sm px-3 py-2 focus:outline-none focus:ring-1 focus:ring-fuchsia-500"
                        >
                          <%= for t <- @field_types do %>
                            <option value={t} selected={field.type == t}><%= t %></option>
                          <% end %>
                        </select>
                      </div>

                      <%= if field.type == "enum" do %>
                        <div class="col-span-2">
                          <label class="block text-sm font-semibold text-zinc-800 mb-1">
                            Options <span class="font-normal text-zinc-400">(comma-separated)</span>
                          </label>
                          <input
                            type="text"
                            value={field.enum_values}
                            placeholder="e.g. red, blue, yellow"
                            phx-change="update_field"
                            phx-value-idx={idx}
                            phx-value-key="enum_values"
                            class="w-full rounded-lg border border-zinc-300 text-zinc-900 text-sm px-3 py-2 focus:outline-none focus:ring-1 focus:ring-fuchsia-500"
                          />
                        </div>
                      <% end %>

                      <div class="col-span-2 flex items-center gap-2">
                        <input
                          type="checkbox"
                          id={"required-#{idx}"}
                          checked={field.required}
                          phx-click="toggle_required"
                          phx-value-idx={idx}
                          class="rounded border-zinc-300 text-fuchsia-600 focus:ring-fuchsia-500"
                        />
                        <label for={"required-#{idx}"} class="text-sm text-zinc-700">Required</label>
                      </div>
                    </div>

                    <button
                      type="button"
                      phx-click="remove_field"
                      phx-value-idx={idx}
                      class="mt-6 text-zinc-400 hover:text-rose-500 transition-colors"
                      aria-label="Remove field"
                    >
                      <.icon name="hero-x-mark" class="w-5 h-5" />
                    </button>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>

        <div class="mt-8 flex gap-3">
          <.button
            phx-click="save_schema"
            class="bg-fuchsia-700 hover:bg-fuchsia-900 text-white px-5 py-2 rounded-lg font-semibold"
            phx-disable-with="Saving..."
          >
            Save schema
          </.button>
          <.link navigate={~p"/platform/games/#{@game.id}"} class="px-5 py-2 text-zinc-600 hover:text-zinc-900 font-semibold">
            Cancel
          </.link>
        </div>
      </div>
    </div>
    """
  end

  def mount(%{"id" => game_id}, _session, socket) do
    game = Platform.get_game!(game_id)
    changeset = Platform.CardSchema |> struct() |> ViralSpiral.Platform.CardSchema.changeset(%{})

    {:ok,
     assign(socket,
       game: game,
       form: to_form(changeset),
       fields: [],
       field_types: @field_types,
       page_title: "New Card Schema"
     )}
  end

  def handle_event("validate", %{"card_schema" => params}, socket) do
    changeset =
      %ViralSpiral.Platform.CardSchema{}
      |> ViralSpiral.Platform.CardSchema.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("add_field", _params, socket) do
    new_field = %{@empty_field | tmp_id: System.unique_integer([:positive])}
    {:noreply, update(socket, :fields, &(&1 ++ [new_field]))}
  end

  def handle_event("remove_field", %{"idx" => idx}, socket) do
    idx = String.to_integer(idx)
    {:noreply, update(socket, :fields, &List.delete_at(&1, idx))}
  end

  def handle_event("update_field", %{"idx" => idx, "key" => key, "value" => value}, socket) do
    idx = String.to_integer(idx)

    fields =
      List.update_at(socket.assigns.fields, idx, fn field ->
        Map.put(field, String.to_existing_atom(key), value)
      end)

    {:noreply, assign(socket, :fields, fields)}
  end

  def handle_event("toggle_required", %{"idx" => idx}, socket) do
    idx = String.to_integer(idx)

    fields =
      List.update_at(socket.assigns.fields, idx, fn field ->
        Map.update!(field, :required, &(!&1))
      end)

    {:noreply, assign(socket, :fields, fields)}
  end

  def handle_event("save_schema", _params, socket) do
    form_data = socket.assigns.form.source.changes
    game = socket.assigns.game

    schema_attrs = %{
      "name" => Map.get(form_data, :name, ""),
      "description" => Map.get(form_data, :description),
      "game_id" => game.id
    }

    with {:ok, schema} <- Platform.create_card_schema(schema_attrs),
         :ok <- save_field_definitions(schema.id, socket.assigns.fields) do
      {:noreply,
       socket
       |> put_flash(:info, "Card schema created.")
       |> push_navigate(to: ~p"/platform/games/#{game.id}")}
    else
      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_field_definitions(schema_id, fields) do
    results =
      fields
      |> Enum.reject(&(&1.name == ""))
      |> Enum.map(fn field ->
        enum_values =
          if field.type == "enum" do
            field.enum_values
            |> String.split(",")
            |> Enum.map(&String.trim/1)
            |> Enum.reject(&(&1 == ""))
          else
            nil
          end

        Platform.create_field_definition(%{
          "name" => field.name,
          "type" => field.type,
          "required" => field.required,
          "default_value" => field.default_value,
          "enum_values" => enum_values,
          "card_schema_id" => schema_id
        })
      end)

    if Enum.any?(results, &match?({:error, _}, &1)) do
      {:error, :field_save_failed}
    else
      :ok
    end
  end
end
