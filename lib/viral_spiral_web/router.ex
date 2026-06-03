defmodule ViralSpiralWeb.Router do
  use ViralSpiralWeb, :router

  import ViralSpiralWeb.UserAuth, only: [fetch_current_user: 2, redirect_if_authenticated: 2, require_authenticated_user: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ViralSpiralWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :require_guest do
    plug :redirect_if_authenticated
  end

  pipeline :require_authenticated do
    plug :require_authenticated_user
  end

  # Auth routes — redirect to home if already logged in
  scope "/", ViralSpiralWeb do
    pipe_through [:browser, :require_guest]

    live "/login", UserLoginLive
    live "/register", UserRegistrationLive
  end

  # Session create/destroy — plain controller (must write to HTTP session)
  scope "/", ViralSpiralWeb do
    pipe_through :browser

    get "/session/create", UserSessionController, :create
    delete "/logout", UserSessionController, :delete

    live "/invites/:token", InviteLive
  end

  # Public game routes
  scope "/", ViralSpiralWeb do
    pipe_through :browser

    live "/", Multiplayer
    live "/room/waiting-room/:room_name", MultiplayerWaitingRoom
    live "/join/:room_name", MultiplayerJoinRoom
    live "/room/:room_name", MultiplayerRoom
    live "/spec/:room_name", SpectatorRoom
  end

  # Designer routes (authenticated)
  scope "/designer", ViralSpiralWeb do
    pipe_through [:browser, :require_authenticated]

    live "/", Home
    live "/waiting-room/:room", WaitingRoom
    live "/room/:room", GameRoom
  end

  # Platform routes (authenticated)
  scope "/platform", ViralSpiralWeb do
    pipe_through [:browser, :require_authenticated]

    live "/games", Platform.GamesLive, :index
    live "/games/new", Platform.GamesLive, :new
    live "/games/:id", Platform.GameDetailLive
    live "/games/:id/schemas/new", Platform.CardSchemaNewLive
    live "/games/:id/cards/new", Platform.CardNewLive
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:viral_spiral, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ViralSpiralWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
