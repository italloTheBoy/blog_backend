defmodule BlogBackend.Repo do
  use Ecto.Repo,
    otp_app: :blog_backend,
    adapter: Ecto.Adapters.Postgres
end
