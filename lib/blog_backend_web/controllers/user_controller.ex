defmodule BlogBackendWeb.UserController do
  use BlogBackendWeb, :controller

  import BlogBackend.Auth

  alias BlogBackend.Auth.User

  def register(conn, params) do
    params
    |> register_user()
    |> case do
      {:ok, user = %User{}} ->
        conn
        |> put_status(201)
        |> json(%{
          message: "Usuario registrado",
          new_user: user
        })

      {:error, changeset = %Ecto.Changeset{}} ->
        conn
        |> put_status(422)
        |> render("register_error.json", changeset: changeset)
    end
  end
end
