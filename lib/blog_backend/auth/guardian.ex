defmodule BlogBackend.Auth.Guardian do
  use Guardian, otp_app: :blog_backend

  import BlogBackend.Auth

  alias BlogBackend.Auth.User

  def subject_for_token(user = %User{}, _claims) do
    {:ok, to_string(user.id)}
  end

  @spec resource_from_claims(map) :: {:error, :resource_not_found} | {:ok, any}
  def resource_from_claims(%{"sub" => id}) do
    {:ok, get_user!(id)}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end
