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
        |> render("register.json", new_user: user)

      {:error, changeset = %Ecto.Changeset{}} ->
        conn
        |> put_status(422)
        |> render("register.json", changeset: changeset)
    end
  end
end
