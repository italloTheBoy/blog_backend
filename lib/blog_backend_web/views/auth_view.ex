defmodule BlogBackendWeb.AuthView do
  use BlogBackendWeb, :view

  import BlogBackendWeb.ChangesetHelpers

  def render("login.json", %{token: token, user: user}) do
    %{
      message: "usuario autenticado",
      token: token,
      user: render_one(user, BlogBackendWeb.UserView, "user.json")
    }
  end

  def render("login.json", %{data: data}) do
    %{
      errors: put_errors("email ou senha invalidos"),
      data: data
    }
  end
end
