defmodule BlogBackendWeb.Router do
  use BlogBackendWeb, :router

  alias BlogBackend.Guardian

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BlogBackendWeb do
    pipe_through [:api, Guardian.Pipeline.EnsureNotAuth]

    post "/login", AuthController, :login

    resources "/user", UserController, only: [:create]
  end

  scope "/api", BlogBackendWeb do
    pipe_through [:api, Guardian.Pipeline.MaybeAuth]

    resources "/user", UserController, only: [:show] do
      resources "/posts", PostController, only: [:index]
      resources "/comments", CommentController, only: [:index]
    end

    resources "/post", PostController, only: [:show] do
      resources "/comments", CommentController, only: [:index]
    end

    resources "/comment", CommentController, only: [:show] do
      resources "/comments", CommentController, only: [:index]
    end
  end

  scope "/api", BlogBackendWeb do
    pipe_through [:api, Guardian.Pipeline.EnsureAuth]

    resources "/user", UserController, only: [:update, :delete]

    resources "/post", PostController, only: [:create, :delete] do
      resources "/comment", CommentController, only: [:create]
      resources "/reaction", ReactionController, only: [:create, :update]
    end

    resources "/comment", CommentController, only: [:delete] do
      resources "/comment", CommentController, only: [:create]
      resources "/reaction", ReactionController, only: [:create, :update]
    end

    resources "/reaction", ReactionController, only: [:show, :delete]
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
