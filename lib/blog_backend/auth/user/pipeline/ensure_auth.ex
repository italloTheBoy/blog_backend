defmodule BlogBackend.Auth.User.Pipeline.EnsureAuth do
  use Guardian.Plug.Pipeline,
    otp_app: :blog_backend,
    module: BlogBackend.Auth.User.Guardian,
    error_handler: BlogBackend.Auth.User.ErrorHandler

  plug Guardian.Plug.EnsureAuthenticated
end
