defmodule ViralSpiralWeb.InviteLive do
  use ViralSpiralWeb, :live_view

  alias ViralSpiral.Invitations
  alias ViralSpiralWeb.UserAuth

  on_mount {UserAuth, :fetch_current_user}

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center bg-gray-50 px-4">
      <div class="w-full max-w-md text-center">
        <%= case @state do %>
          <% :valid -> %>
            <div class="bg-white py-10 px-8 shadow rounded-lg">
              <h1 class="text-2xl font-bold text-gray-900 mb-2">You're invited!</h1>
              <p class="text-gray-600 mb-1">
                Join <strong><%= @invite.game.name %></strong> as a
                <strong><%= role_label(@invite.role) %></strong>.
              </p>

              <%= if @current_user do %>
                <p class="text-sm text-gray-500 mb-6">
                  Accepting as <strong><%= @current_user.email %></strong>
                </p>
                <.button
                  phx-click="accept"
                  class="w-full bg-fuchsia-700 hover:bg-fuchsia-900 text-white py-2 px-4 rounded-md font-semibold transition-colors"
                  phx-disable-with="Accepting..."
                >
                  Accept invitation
                </.button>
              <% else %>
                <p class="text-sm text-gray-500 mb-6">
                  Create an account or sign in to accept.
                </p>
                <div class="flex flex-col gap-3">
                  <.link
                    navigate={~p"/register?invite_token=#{@token}"}
                    class="w-full bg-fuchsia-700 hover:bg-fuchsia-900 text-white py-2 px-4 rounded-md font-semibold transition-colors text-center"
                  >
                    Create account & accept
                  </.link>
                  <.link
                    navigate={~p"/login?invite_token=#{@token}"}
                    class="w-full border border-fuchsia-700 text-fuchsia-700 hover:bg-fuchsia-50 py-2 px-4 rounded-md font-semibold transition-colors text-center"
                  >
                    Sign in & accept
                  </.link>
                </div>
              <% end %>
            </div>

          <% :already_accepted -> %>
            <div class="bg-white py-10 px-8 shadow rounded-lg">
              <h1 class="text-2xl font-bold text-gray-900 mb-2">Already accepted</h1>
              <p class="text-gray-600 mb-6">This invitation has already been used.</p>
              <.link navigate={~p"/"} class="font-medium text-fuchsia-700 hover:text-fuchsia-900">
                Go to home
              </.link>
            </div>

          <% :expired -> %>
            <div class="bg-white py-10 px-8 shadow rounded-lg">
              <h1 class="text-2xl font-bold text-gray-900 mb-2">Invitation expired</h1>
              <p class="text-gray-600">This invitation link has expired. Ask the game owner to send a new one.</p>
            </div>

          <% :not_found -> %>
            <div class="bg-white py-10 px-8 shadow rounded-lg">
              <h1 class="text-2xl font-bold text-gray-900 mb-2">Invalid invitation</h1>
              <p class="text-gray-600">This invitation link is not valid.</p>
            </div>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    {state, invite} =
      case Invitations.get_pending_invite(token) do
        {:ok, invite} -> {:valid, invite}
        {:error, :already_accepted} -> {:already_accepted, nil}
        {:error, :expired} -> {:expired, nil}
        {:error, :not_found} -> {:not_found, nil}
      end

    {:ok,
     assign(socket,
       state: state,
       invite: invite,
       token: token,
       page_title: "Invitation"
     )}
  end

  def handle_event("accept", _params, socket) do
    user = socket.assigns.current_user
    token = socket.assigns.token

    case Invitations.accept(token, user) do
      {:ok, _invite} ->
        {:noreply,
         socket
         |> put_flash(:info, "You've joined #{socket.assigns.invite.game.name}!")
         |> redirect(to: ~p"/")}

      {:error, reason} ->
        message =
          case reason do
            :already_accepted -> "This invitation has already been accepted."
            :expired -> "This invitation has expired."
            _ -> "Could not accept invitation."
          end

        {:noreply, put_flash(socket, :error, message)}
    end
  end

  defp role_label(:collaborator), do: "collaborator"
  defp role_label(:playtester), do: "playtester"
end
