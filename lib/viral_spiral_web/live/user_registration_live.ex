defmodule ViralSpiralWeb.UserRegistrationLive do
  use ViralSpiralWeb, :live_view

  alias ViralSpiral.Accounts
  alias ViralSpiral.Accounts.User
  alias ViralSpiralWeb.UserAuth
  alias ViralSpiralWeb.UserSessionController

  on_mount {UserAuth, :redirect_if_authenticated}

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center bg-gray-50 px-4">
      <div class="w-full max-w-md">
        <div class="text-center mb-8">
          <h1 class="text-3xl font-bold text-gray-900">Create an account</h1>
          <%= if @invite_token do %>
            <p class="mt-2 text-sm text-gray-600">
              You were invited to join <strong><%= @invite_game_name %></strong>.
              Sign up to accept.
            </p>
          <% else %>
            <p class="mt-2 text-sm text-gray-600">
              Already have an account?
              <.link navigate={~p"/login"} class="font-medium text-fuchsia-700 hover:text-fuchsia-900">
                Sign in
              </.link>
            </p>
          <% end %>
        </div>

        <div class="bg-white py-8 px-6 shadow rounded-lg">
          <.simple_form for={@form} id="registration-form" phx-submit="register" phx-change="validate">
            <.input field={@form[:name]} type="text" label="Name" autocomplete="name" />
            <.input field={@form[:email]} type="email" label="Email" autocomplete="email" />
            <.input
              field={@form[:password]}
              type="password"
              label="Password"
              autocomplete="new-password"
            />
            <:actions>
              <.button
                class="w-full bg-fuchsia-700 hover:bg-fuchsia-900 text-white py-2 px-4 rounded-md font-semibold transition-colors"
                phx-disable-with="Creating account..."
              >
                Create account
              </.button>
            </:actions>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end

  def mount(params, _session, socket) do
    invite_token = params["invite_token"]

    {invite_game_name} =
      if invite_token do
        case ViralSpiral.Invitations.get_pending_invite(invite_token) do
          {:ok, invite} -> {invite.game.name}
          _ -> {nil}
        end
      else
        {nil}
      end

    changeset = User.registration_changeset(%User{}, %{})

    {:ok,
     assign(socket,
       form: to_form(changeset, as: :user),
       invite_token: invite_token,
       invite_game_name: invite_game_name,
       page_title: "Sign up"
     )}
  end

  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      %User{}
      |> User.registration_changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset, as: :user))}
  end

  def handle_event("register", %{"user" => params}, socket) do
    case Accounts.register_user(params) do
      {:ok, user} ->
        token = UserSessionController.sign_token(user.id)

        redirect_url =
          if socket.assigns.invite_token do
            ~p"/session/create?token=#{token}&invite_token=#{socket.assigns.invite_token}"
          else
            ~p"/session/create?token=#{token}"
          end

        {:noreply, redirect(socket, to: redirect_url)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: :user))}
    end
  end
end
