defmodule BlogBackendWeb.AuthView do
  use BlogBackendWeb, :view

  def render("login.json", %{token: token, user: user}) do
    %{
      message: "usuario autenticado",
      token: token,
      user: render_one(user, BlogBackendWeb.UserView, "user.json")
    }
  end

  def render("login.json", %{data: data}) do
    %{
      data: data,
      error: %{
        message: "email ou senha invalidos"
      }
    }
  end
end
