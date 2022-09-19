defmodule BlogBackend.Auth.User.Guardian do
  use Guardian, otp_app: :blog_backend

  import BlogBackend.Auth

  alias BlogBackend.Auth.User

  def subject_for_token(%User{id: user_id}, _claims) do
    {:ok, to_string(user_id)}
  end

  @spec resource_from_claims(map) :: {:error, :resource_not_found} | {:ok, any}
  def resource_from_claims(%{"sub" => id}) do
    user = get_user!(id)
    {:ok, user}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end
