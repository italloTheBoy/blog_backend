defmodule BlogBackendWeb.AuthView do
  use BlogBackendWeb, :view

  def render("login.json", %{token: token}) do
    %{
      message: "usuario autenticado",
      token: "Bearer #{token}"
    }
  end

  def render("login.json", %{data: data}) do
    %{
      message: "email ou senha invalidos",
      data: data
    }
  end
end
