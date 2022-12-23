defmodule BlogBackend.Guardian.Pipeline.EnsureNotAuth do
  use Guardian.Plug.Pipeline,
    otp_app: :blog_backend,
    module: BlogBackend.Guardian,
    error_handler: BlogBackend.ErrorHandler

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureNotAuthenticated
  plug Guardian.Plug.LoadResource, allow_blank: true
end
