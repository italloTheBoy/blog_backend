defmodule BlogBackend.Auth.Pipeline.MaybeAuth do
  use Guardian.Plug.Pipeline,
    otp_app: :blog_backend,
    module: BlogBackend.Auth.Guardian,
    error_handler: BlogBackend.Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end
