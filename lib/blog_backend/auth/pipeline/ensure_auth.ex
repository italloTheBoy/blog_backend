defmodule BlogBackend.Auth.Pipeline.EnsureAuth do
  use Guardian.Plug.Pipeline,
    otp_app: :blog_backend,
    module: BlogBackend.Auth.Guardian,
    error_handler: BlogBackend.Auth.ErrorHandler

  plug Guardian.Plug.EnsureAuthenticated
end
