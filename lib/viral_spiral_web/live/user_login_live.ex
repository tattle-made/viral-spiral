defmodule ViralSpiralWeb.UserLoginLive do
  use ViralSpiralWeb, :live_view

  alias ViralSpiral.Accounts
  alias ViralSpiralWeb.UserAuth
  alias ViralSpiralWeb.UserSessionController

  on_mount {UserAuth, :redirect_if_authenticated}

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center bg-gray-50 px-4">
      <div class="w-full max-w-md">
        <div class="text-center mb-8">
          <h1 class="text-3xl font-bold text-gray-900">Sign in</h1>
          <p class="mt-2 text-sm text-gray-600">
            Don't have an account?
            <.link navigate={~p"/register"} class="font-medium text-fuchsia-700 hover:text-fuchsia-900">
              Sign up
            </.link>
          </p>
        </div>

        <div class="bg-white py-8 px-6 shadow rounded-lg">
          <.simple_form for={@form} id="login-form" phx-submit="login" phx-change="validate">
            <.input field={@form[:email]} type="email" label="Email" autocomplete="email" />
            <.input
              field={@form[:password]}
              type="password"
              label="Password"
              autocomplete="current-password"
            />
            <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
            <:actions>
              <.button
                class="w-full bg-fuchsia-700 hover:bg-fuchsia-900 text-white py-2 px-4 rounded-md font-semibold transition-colors"
                phx-disable-with="Signing in..."
              >
                Sign in
              </.button>
            </:actions>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    form = to_form(%{"email" => "", "password" => "", "remember_me" => false}, as: :user)
    {:ok, assign(socket, form: form, page_title: "Sign in")}
  end

  def handle_event("validate", %{"user" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: :user))}
  end

  def handle_event("login", %{"user" => params}, socket) do
    %{"email" => email, "password" => password} = params

    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        token = UserSessionController.sign_token(user.id)

        {:noreply,
         redirect(socket, to: ~p"/session/create?token=#{token}&remember_me=#{params["remember_me"] || "false"}")}

      {:error, :invalid_credentials} ->
        form = to_form(Map.put(params, "password", ""), as: :user)

        {:noreply,
         socket
         |> put_flash(:error, "Invalid email or password.")
         |> assign(form: form)}
    end
  end
end
