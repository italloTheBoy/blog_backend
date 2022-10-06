defmodule BlogBackend.Auth.Guardian do
  use Guardian, otp_app: :blog_backend

  import BlogBackend.Auth

  alias BlogBackend.Auth.User

  @spec subject_for_token(%User{:id => integer}, any) :: {:ok, binary}
  def subject_for_token(user = %User{}, _claims) do
    {:ok, to_string(user.id)}
  end

  @spec resource_from_claims(map) :: {:error, :resource_not_found} | {:ok, %User{}}
  def resource_from_claims(%{"sub" => id}) do
    {:ok, get_user!(id)}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end
