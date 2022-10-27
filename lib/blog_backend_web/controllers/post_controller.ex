defmodule BlogBackendWeb.PostController do
  use BlogBackendWeb, :controller

  import BlogBackend.Timeline

  alias BlogBackend.Timeline.Post

  @spec create(Plug.Conn.t(), Post.t()) :: Plug.Conn.t()
  def create(conn, params) do
    params
    |> create_post()
    |> case do
      {:ok, %Post{} = post} ->
        conn
        |> put_status(201)
        |> render("create.json", status: 201, post: post)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(422)
        |> render("create.json", status: 422, changeset: changeset)
    end
  end

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"id" => post_id}) do
    case get_post(post_id) do
      %Post{} = post ->
        conn
        |> put_status(200)
        |> render("show.json", status: 200, post: post)

      nil ->
        conn
        |> put_status(404)
        |> render("show.json", status: 404)
    end
  end

  @spec delete(Plug.Conn.t(), map) :: Plug.Conn.t()
  def delete(conn, %{"id" => post_id}) do
    case get_post(post_id) do
      %Post{} = post ->
        {:ok, %Post{} = deleted_post} = delete_post(post)

        conn
        |> put_status(200)
        |> render("delete.json", status: 200, post: deleted_post)

      nil ->
        conn
        |> put_status(404)
        |> render("delete.json", status: 404)
    end
  end
end
