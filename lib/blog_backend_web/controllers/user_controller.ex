defmodule BlogBackendWeb.UserController do
  use BlogBackendWeb, :controller

  import BlogBackend.Auth

  alias BlogBackend.Auth.User

  @spec register(
          Plug.Conn.t(),
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Plug.Conn.t()
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

  def show(conn, %{"user_id" => user_id}) do
    case get_user(user_id) do
      user = %User{} ->
        conn
        |> put_status(200)
        |> render("show.json", user: user)

      nil ->
        conn
        |> put_status(404)
        |> render("show.json")
    end
  end

  @spec delete(Plug.Conn.t(), map) :: Plug.Conn.t()
  def delete(conn, %{"user_id" => user_id}) do
    case get_user(user_id) do
      user = %User{} ->
        delete_user(user)

        conn
        |> put_status(200)
        |> render("delete.json", is_deleted: true)

      nil ->
        conn
        |> put_status(404)
        |> render("delete.json", is_deleted: false)
    end
  end
end
