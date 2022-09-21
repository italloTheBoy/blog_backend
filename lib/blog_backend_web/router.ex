defmodule BlogBackendWeb.Router do
  use BlogBackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :maybe_auth do
    plug BlogBackend.Auth.User.Pipeline.MaybeAuth
  end

  pipeline :ensure_auth do
    plug BlogBackend.Auth.User.Pipeline.EnsureAuth
  end

  scope "/api", BlogBackendWeb do
    pipe_through [:api, :maybe_auth]

    post "/login", AuthController, :login
    delete "/logout", AuthController, :logout

    resources "/users", UserController, only: [:create, :show]
  end

  scope "/api", BlogBackendWeb do
    pipe_through [:api, :maybe_auth, :ensure_auth]

    resources "/users", UserController, only: [:update, :delete]
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: BlogBackendWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
