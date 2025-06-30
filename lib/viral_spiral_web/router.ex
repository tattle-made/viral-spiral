defmodule ViralSpiralWeb.Router do
  use ViralSpiralWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ViralSpiralWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ViralSpiralWeb do
    pipe_through :browser

    # get "/", PageController, :home
    live "/", Home
    live "/waiting-room/:room", WaitingRoom
    live "/room/:room", GameRoom
  end

  scope "/multiplayer", ViralSpiralWeb do
    pipe_through :browser

    live "/", Multiplayer
    live "/join/:room_name", MultiplayerJoinRoom
    live "/room/waiting-room/:room_name", MultiplayerWaitingRoom
    live "/room/:room_name", MultiplayerRoom
  end

  # Other scopes may use custom stacks.
  # scope "/api", ViralSpiralWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:viral_spiral, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ViralSpiralWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
