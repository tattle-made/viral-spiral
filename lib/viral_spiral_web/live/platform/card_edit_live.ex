defmodule ViralSpiralWeb.Platform.CardEditLive do
  use ViralSpiralWeb, :live_view

  alias ViralSpiral.{Platform, Repo, S3}
  alias ViralSpiralWeb.UserAuth

  on_mount {UserAuth, :require_authenticated}

  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto px-4 py-10">
      <.back navigate={@back_path}>
        <%= @schema.name %>
      </.back>

      <h1 class="mt-6 text-2xl font-bold text-zinc-900">Edit Card</h1>
      <p class="mt-1 text-sm text-zinc-500">Schema: <strong><%= @schema.name %></strong></p>

      <div class="mt-8 bg-white border border-zinc-200 rounded-xl shadow-sm p-6">
        <form phx-submit="save_card" phx-change="validate_card">
          <%!-- Label --%>
          <div class="mb-5">
            <label class="block text-sm font-semibold text-zinc-800 mb-1">Label</label>
            <input
              type="text"
              name="card[label]"
              value={@label}
              placeholder="A short internal name for this card"
              class="w-full rounded-lg border border-zinc-300 text-zinc-900 text-sm px-3 py-2 focus:outline-none focus:ring-1 focus:ring-fuchsia-500"
            />
            <%= if @errors[:label] do %>
              <p class="mt-1 text-xs text-rose-600"><%= @errors[:label] %></p>
            <% end %>
          </div>

          <%!-- Image upload --%>
          <div class="mb-5">
            <label class="block text-sm font-semibold text-zinc-800 mb-1">Image</label>
            <div class="border-2 border-dashed border-zinc-300 rounded-lg p-4 text-center hover:border-fuchsia-400 transition-colors">
              <.live_file_input upload={@uploads.image} class="sr-only" />
              <label for={@uploads.image.ref} class="cursor-pointer">
                <%= cond do %>
                  <% @uploads.image.entries != [] -> %>
                    <%= for entry <- @uploads.image.entries do %>
                      <div class="relative inline-block">
                        <.live_img_preview entry={entry} class="max-h-48 rounded-lg object-contain mx-auto" />
                        <button
                          type="button"
                          phx-click="cancel_upload"
                          phx-value-ref={entry.ref}
                          class="absolute -top-2 -right-2 bg-rose-500 text-white rounded-full w-5 h-5 flex items-center justify-center text-xs hover:bg-rose-700"
                          aria-label="Remove image"
                        >
                          ✕
                        </button>
                      </div>
                      <%= for err <- upload_errors(@uploads.image, entry) do %>
                        <p class="text-xs text-rose-600 mt-1"><%= upload_error_to_string(err) %></p>
                      <% end %>
                    <% end %>
                  <% @card.image_key != nil -> %>
                    <div class="py-2">
                      <img
                        src={S3.public_url(@card.image_key)}
                        class="max-h-48 rounded-lg object-contain mx-auto"
                      />
                      <p class="text-xs text-zinc-400 mt-2">Click to replace image</p>
                    </div>
                  <% true -> %>
                    <div class="py-4">
                      <.icon name="hero-photo" class="w-8 h-8 text-zinc-300 mx-auto mb-2" />
                      <p class="text-sm text-zinc-500">Click to upload an image</p>
                      <p class="text-xs text-zinc-400 mt-1">JPG, PNG, WebP up to 5MB</p>
                    </div>
                <% end %>
              </label>
            </div>
          </div>

          <%!-- Dynamic attribute fields from schema --%>
          <%= if @field_definitions != [] do %>
            <div class="border-t border-zinc-100 pt-5 mb-5">
              <h2 class="text-sm font-semibold text-zinc-500 uppercase tracking-wide mb-4">Card Attributes</h2>
              <div class="space-y-4">
                <%= for field <- @field_definitions do %>
                  <div>
                    <label class="block text-sm font-semibold text-zinc-800 mb-1">
                      <%= field.name %>
                      <%= if field.required do %>
                        <span class="text-fuchsia-600">*</span>
                      <% end %>
                    </label>

                    <%= case field.type do %>
                      <% "boolean" -> %>
                        <input
                          type="checkbox"
                          name={"card[attributes][#{field.name}]"}
                          checked={Map.get(@attributes, field.name) in [true, "true"]}
                          class="rounded border-zinc-300 text-fuchsia-600 focus:ring-fuchsia-500"
                        />

                      <% "enum" -> %>
                        <select
                          name={"card[attributes][#{field.name}]"}
                          class="w-full rounded-lg border border-zinc-300 text-zinc-900 text-sm px-3 py-2 focus:outline-none focus:ring-1 focus:ring-fuchsia-500"
                        >
                          <option value="">— select —</option>
                          <%= for opt <- (field.enum_values || []) do %>
                            <option value={opt} selected={Map.get(@attributes, field.name) == opt}>
                              <%= opt %>
                            </option>
                          <% end %>
                        </select>

                      <% "integer" -> %>
                        <input
                          type="number"
                          name={"card[attributes][#{field.name}]"}
                          value={Map.get(@attributes, field.name)}
                          class="w-full rounded-lg border border-zinc-300 text-zinc-900 text-sm px-3 py-2 focus:outline-none focus:ring-1 focus:ring-fuchsia-500"
                        />

                      <% _ -> %>
                        <input
                          type="text"
                          name={"card[attributes][#{field.name}]"}
                          value={Map.get(@attributes, field.name)}
                          class="w-full rounded-lg border border-zinc-300 text-zinc-900 text-sm px-3 py-2 focus:outline-none focus:ring-1 focus:ring-fuchsia-500"
                        />
                    <% end %>

                    <%= if @errors[field.name] do %>
                      <p class="mt-1 text-xs text-rose-600"><%= @errors[field.name] %></p>
                    <% end %>
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>

          <div class="flex gap-3 pt-2">
            <button
              type="submit"
              class="bg-fuchsia-700 hover:bg-fuchsia-900 text-white px-5 py-2 rounded-lg font-semibold text-sm transition-colors phx-submit-loading:opacity-70"
              phx-disable-with="Saving..."
            >
              Save card
            </button>
            <.link
              navigate={@back_path}
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

  def mount(%{"id" => game_id, "card_id" => card_id}, _session, socket) do
    game = Platform.get_game!(game_id)
    card = Platform.get_card!(card_id)
    schema = Platform.get_card_schema!(card.card_schema_id) |> Repo.preload(:field_definitions)
    back_path = ~p"/platform/games/#{game_id}/schemas/#{card.card_schema_id}/cards"

    socket =
      socket
      |> assign(
        game: game,
        card: card,
        schema: schema,
        field_definitions: schema.field_definitions,
        label: card.label || "",
        attributes: card.attributes || %{},
        errors: %{},
        back_path: back_path,
        page_title: "Edit Card"
      )
      |> allow_upload(:image,
        accept: ~w(.jpg .jpeg .png .webp .gif),
        max_entries: 1,
        max_file_size: 5_000_000
      )

    {:ok, socket}
  end

  def handle_event("validate_card", %{"card" => params}, socket) do
    {:noreply,
     assign(socket,
       label: params["label"] || "",
       attributes: params["attributes"] || %{}
     )}
  end

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  def handle_event("save_card", %{"card" => params}, socket) do
    label = params["label"] || ""
    attributes = params["attributes"] || %{}

    label_errors =
      if String.trim(label) == "", do: %{label: "Label is required"}, else: %{}

    attr_errors =
      socket.assigns.field_definitions
      |> Enum.filter(& &1.required)
      |> Enum.reduce(%{}, fn field, acc ->
        value = Map.get(attributes, field.name, "")
        if is_nil(value) or String.trim(to_string(value)) == "" do
          Map.put(acc, field.name, "#{field.name} is required")
        else
          acc
        end
      end)

    errors = Map.merge(label_errors, attr_errors)

    if map_size(errors) > 0 do
      {:noreply, assign(socket, errors: errors, label: label, attributes: attributes)}
    else
      new_image_key =
        consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
          key = S3.card_image_key(socket.assigns.card.id, entry.client_name)
          binary = File.read!(path)

          case S3.upload(binary, key, entry.client_type) do
            {:ok, _} -> {:ok, key}
            {:error, _} -> {:postpone, nil}
          end
        end)
        |> List.first()

      image_key = new_image_key || socket.assigns.card.image_key

      card_attrs = %{
        "label" => label,
        "image_key" => image_key,
        "attributes" => attributes
      }

      case Platform.update_card(socket.assigns.card, card_attrs) do
        {:ok, _card} ->
          {:noreply,
           socket
           |> put_flash(:info, "Card updated.")
           |> push_navigate(to: socket.assigns.back_path)}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Could not update card. Please try again.")}
      end
    end
  end

  defp upload_error_to_string(:too_large), do: "File is too large (max 5MB)"
  defp upload_error_to_string(:too_many_files), do: "Only one image allowed"
  defp upload_error_to_string(:not_accepted), do: "File type not supported"
  defp upload_error_to_string(_), do: "Upload failed"
end
