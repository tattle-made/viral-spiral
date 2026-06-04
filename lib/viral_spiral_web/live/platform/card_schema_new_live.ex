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
        <form phx-submit="save_schema" phx-change="validate" class="space-y-5">
          <%!-- Schema name --%>
          <div>
            <label class="block text-sm font-semibold text-zinc-800 mb-1">
              Schema name <span class="text-rose-500">*</span>
            </label>
            <input
              type="text"
              name="schema[name]"
              value={@schema_name}
              placeholder="e.g. Affinity Card, News Card"
              class="w-full rounded-lg border border-zinc-300 text-zinc-900 text-sm px-3 py-2 focus:outline-none focus:ring-1 focus:ring-fuchsia-500"
            />
            <%= if @errors[:name] do %>
              <p class="mt-1 text-xs text-rose-600"><%= @errors[:name] %></p>
            <% end %>
          </div>

          <%!-- Schema description --%>
          <div>
            <label class="block text-sm font-semibold text-zinc-800 mb-1">
              Description <span class="font-normal text-zinc-400">(optional)</span>
            </label>
            <textarea
              name="schema[description]"
              placeholder="What kind of cards use this schema?"
              rows="3"
              class="w-full rounded-lg border border-zinc-300 text-zinc-900 text-sm px-3 py-2 focus:outline-none focus:ring-1 focus:ring-fuchsia-500 resize-none"
            ><%= @schema_description %></textarea>
          </div>

          <%!-- Field definitions --%>
          <div class="pt-4 border-t border-zinc-100">
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
                            name={"fields[#{idx}][name]"}
                            value={field.name}
                            placeholder="e.g. headline"
                            class="w-full rounded-lg border border-zinc-300 text-zinc-900 text-sm px-3 py-2 focus:outline-none focus:ring-1 focus:ring-fuchsia-500"
                          />
                        </div>
                        <div>
                          <label class="block text-sm font-semibold text-zinc-800 mb-1">Type</label>
                          <select
                            name={"fields[#{idx}][type]"}
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
                              name={"fields[#{idx}][enum_values]"}
                              value={field.enum_values}
                              placeholder="e.g. red, blue, yellow"
                              class="w-full rounded-lg border border-zinc-300 text-zinc-900 text-sm px-3 py-2 focus:outline-none focus:ring-1 focus:ring-fuchsia-500"
                            />
                          </div>
                        <% end %>

                        <div class="col-span-2 flex items-center gap-2">
                          <input
                            type="checkbox"
                            id={"required-#{field.tmp_id}"}
                            name={"fields[#{idx}][required]"}
                            checked={field.required}
                            class="rounded border-zinc-300 text-fuchsia-600 focus:ring-fuchsia-500"
                          />
                          <label for={"required-#{field.tmp_id}"} class="text-sm text-zinc-700">Required</label>
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

          <div class="flex gap-3 pt-4">
            <button
              type="submit"
              class="bg-fuchsia-700 hover:bg-fuchsia-900 text-white px-5 py-2 rounded-lg font-semibold text-sm transition-colors phx-submit-loading:opacity-70"
              phx-disable-with="Saving..."
            >
              Save schema
            </button>
            <.link
              navigate={~p"/platform/games/#{@game.id}"}
              class="px-5 py-2 text-zinc-600 hover:text-zinc-900 font-semibold text-sm"
            >
              Cancel
            </.link>
          </div>
        </form>
      </div>
    </div>
    """
  end

  def mount(%{"id" => game_id}, _session, socket) do
    game = Platform.get_game!(game_id)

    {:ok,
     assign(socket,
       game: game,
       schema_name: "",
       schema_description: "",
       fields: [],
       errors: %{},
       field_types: @field_types,
       page_title: "New Card Schema"
     )}
  end

  def handle_event("validate", params, socket) do
    schema_params = params["schema"] || %{}
    fields = parse_fields(params["fields"] || %{}, socket.assigns.fields)

    {:noreply,
     assign(socket,
       schema_name: schema_params["name"] || "",
       schema_description: schema_params["description"] || "",
       fields: fields,
       errors: %{}
     )}
  end

  def handle_event("add_field", _params, socket) do
    new_field = %{@empty_field | tmp_id: System.unique_integer([:positive])}
    {:noreply, update(socket, :fields, &(&1 ++ [new_field]))}
  end

  def handle_event("remove_field", %{"idx" => idx}, socket) do
    idx = String.to_integer(idx)
    {:noreply, update(socket, :fields, &List.delete_at(&1, idx))}
  end

  def handle_event("save_schema", params, socket) do
    schema_params = params["schema"] || %{}
    name = String.trim(schema_params["name"] || "")
    description = schema_params["description"]
    fields = parse_fields(params["fields"] || %{}, socket.assigns.fields)

    if name == "" do
      {:noreply, assign(socket, errors: %{name: "Name is required"}, fields: fields)}
    else
      schema_attrs = %{
        "name" => name,
        "description" => if(description && String.trim(description) != "", do: description, else: nil),
        "game_id" => socket.assigns.game.id
      }

      with {:ok, schema} <- Platform.create_card_schema(schema_attrs),
           :ok <- save_field_definitions(schema.id, fields) do
        {:noreply,
         socket
         |> put_flash(:info, "Card schema created.")
         |> push_navigate(to: ~p"/platform/games/#{socket.assigns.game.id}")}
      else
        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Could not save schema. Please try again.")}
      end
    end
  end

  defp parse_fields(fields_params, existing_fields) do
    existing_fields
    |> Enum.with_index()
    |> Enum.map(fn {field, idx} ->
      data = Map.get(fields_params, to_string(idx), %{})

      %{
        field
        | name: Map.get(data, "name", field.name),
          type: Map.get(data, "type", field.type),
          required: Map.get(data, "required") == "on",
          enum_values: Map.get(data, "enum_values", field.enum_values)
      }
    end)
  end

  defp save_field_definitions(schema_id, fields) do
    results =
      fields
      |> Enum.reject(&(String.trim(&1.name) == ""))
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
          "name" => String.trim(field.name),
          "type" => field.type,
          "required" => field.required,
          "default_value" => field.default_value,
          "enum_values" => enum_values,
          "card_schema_id" => schema_id
        })
      end)

    if Enum.any?(results, &match?({:error, _}, &1)), do: {:error, :field_save_failed}, else: :ok
  end
end
