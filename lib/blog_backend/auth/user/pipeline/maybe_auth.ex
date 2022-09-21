defmodule BlogBackend.Auth.User.Pipeline.MaybeAuth do
  use Guardian.Plug.Pipeline,
    otp_app: :blog_backend,
    module: BlogBackend.Auth.User.Guardian,
    error_handler: BlogBackend.Auth.User.ErrorHandler

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end
