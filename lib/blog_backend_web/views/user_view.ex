defmodule BlogBackendWeb.UserView do
  use BlogBackendWeb, :view

  alias BlogBackend.Auth.User

  @user_fields [
    :id,
    :email,
    :username
  ]

  def render("token.json", %{token: token}),
    do: %{
      data: %{token: token}
    }

  def render("index.json", %{users: users})
      when is_list(users),
      do: %{
        data: render_many(users, __MODULE__, "user.json")
      }

  def render("id.json", %{user: %User{} = user}),
    do: %{
      data: render("user.json", user: user, only: [:id])
    }

  def render("show.json", %{user: %User{} = user}),
    do: %{
      data: render("user.json", user: user)
    }

  def render("user.json", %{user: %User{} = user, only: selected_fields})
      when is_list(selected_fields),
      do: Map.take(user, selected_fields)

  def render("user.json", %{user: %User{} = user}),
    do: Map.take(user, @user_fields)
end
