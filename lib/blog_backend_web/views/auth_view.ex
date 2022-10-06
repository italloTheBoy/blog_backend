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
      message: "email ou senha invalidos",
      data: data
    }
  end
end
