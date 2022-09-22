defmodule BlogBackendWeb.AuthView do
  use BlogBackendWeb, :view

  def render("login.json", %{token: token}) do
    %{
      message: "usuario autenticado",
      token: token
    }
  end

  def render("login.json", %{data: data}) do
    %{
      message: "email ou senha invalidos",
      data: data
    }
  end
end
