defmodule BlogBackend.Guardian.Pipeline.EnsureAuth do
  use Guardian.Plug.Pipeline,
    otp_app: :blog_backend,
    module: BlogBackend.Guardian,
    error_handler: BlogBackend.ErrorHandler

  @claims %{typ: "access"}

  plug Guardian.Plug.VerifyHeader, claims: @claims, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, allow_blank: true
end
