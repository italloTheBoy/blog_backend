defmodule BlogBackend.Auth.Policy do
  @behaviour Bodyguard.Policy

  alias BlogBackend.Auth.User

  @permitted_actions [:update_user, :delete_user]

  @spec authorize(atom, User.t(), User.t()) ::
          :ok | {:error, :forbidden}
  def authorize(action, %User{id: id}, %User{id: id})
      when action in @permitted_actions,
      do: :ok

  def authorize(_action, _user, _params), do: {:error, :forbidden}
end
