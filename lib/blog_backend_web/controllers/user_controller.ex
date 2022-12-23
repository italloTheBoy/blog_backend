defmodule BlogBackendWeb.UserController do
  use BlogBackendWeb, :controller

  import Ecto.Query, warn: false

  alias BlogBackend.Guardian
  alias BlogBackend.Auth
  alias BlogBackend.Auth.User

  @spec create(
          Plug.Conn.t(),
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Plug.Conn.t()
  def create(conn, params) do
    params
    |> Auth.create_user()
    |> case do
      {:ok, user = %User{}} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user, %{"typ" => "access"})

        conn
        |> put_status(201)
        |> render("register.json", user: user, token: token)

      {:error, changeset = %Ecto.Changeset{}} ->
        conn
        |> put_status(422)
        |> render("register.json", changeset: changeset)
    end
  end

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"id" => user_id}) do
    case Auth.get_user(user_id) do
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

  @spec update(Plug.Conn.t(), map) :: Plug.Conn.t()
  def update(conn, %{"id" => user_id, "changes" => changes}) do
    user = Auth.get_user(user_id)

    if user do
      user
      |> Auth.update_user(changes)
      |> case do
        {:ok, updated_user = %User{}} ->
          conn
          |> put_status(200)
          |> render("update.json", updated_user: updated_user)

        {:error, changeset = %Ecto.Changeset{}} ->
          IO.inspect(changeset)

          conn
          |> put_status(422)
          |> render("update.json", changeset: changeset)
      end
    else
      conn
      |> put_status(404)
      |> render("update.json")
    end
  end

  @spec delete(Plug.Conn.t(), map) :: Plug.Conn.t()
  def delete(conn, %{"id" => user_id}) do
    case Auth.get_user(user_id) do
      user = %User{} ->
        Auth.delete_user(user)

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
