defmodule BlogBackend.Guardian do
  use Guardian, otp_app: :blog_backend

  import BlogBackend.Auth

  alias BlogBackend.Auth.User

  @spec subject_for_token(User.t(), any) :: {:ok, binary}
  def subject_for_token(%User{id: id}, _claims), do: {:ok, to_string("User:#{id}")}
  def subject_for_token(_, _), do: {:error, :unhandled_resource_type}

  @spec resource_from_claims(map) :: {:error, :unhandled_resource_type} | {:ok, %User{} | nil}
  def resource_from_claims(%{"sub" => "User:" <> id}),
    do: get_user(id)

  def resource_from_claims(_), do: {:error, :unhandled_resource_type}
end
