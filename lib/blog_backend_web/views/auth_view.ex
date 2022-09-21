defmodule BlogBackendWeb.AuthView do
  use BlogBackendWeb, :view

  alias BlogBackend.Auth.User

  def render("login.json", %{current_user: current_user = %User{}}) do
    %{
      message: "usuario autenticado",
      user: Map.take(
        current_user,
        [:id, :email, :username, :inserted_at, :updated_at]
      )
    }
  end

  def render("login.json", %{data: data}) do
    %{
      message: "email ou senha invalidos",
      data: data
    }
  end

  def render("user.json", %{user: user = %User{}}) do
    Map.take(
      user,
      [:id, :email, :username, :inserted_at, :updated_at]
    )
  end
end
