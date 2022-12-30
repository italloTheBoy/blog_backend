defmodule BlogBackendWeb.PostController do
  use BlogBackendWeb, :controller

  import BlogBackend.{Auth, Timeline}

  alias BlogBackend.Timeline
  alias BlogBackendWeb.FallbackController

  action_fallback(FallbackController)

  @spec index(Plug.Conn.t(), map) :: FallbackController.t()
  def index(conn, %{"user_id" => id}) do
    with(
      {:ok, user} <- pick_user(id),
      posts <- list_user_posts(user)
    ) do
      render(conn, "index.json", posts: posts)
    end
  end

  @spec create(Plug.Conn.t(), map) :: FallbackController.t()
  def create(conn, %{"post" => params}) do
    with(
      {:ok, user} <- get_current_user(conn),
      {:ok, post} <-
        params
        |> Map.merge(%{"user_id" => user.id})
        |> create_post()
    ) do
      conn
      |> put_status(201)
      |> render("id.json", post: post)
    end
  end

  @spec show(Plug.Conn.t(), map) :: FallbackController.t()
  def show(conn, %{"id" => id}) do
    with {:ok, post} <- get_post(id) do
      render(conn, "show.json", post: post)
    end
  end

  @spec delete(Plug.Conn.t(), map) :: FallbackController.t()
  def delete(conn, %{"id" => post_id}) do
    with(
      {:ok, user} <- get_current_user(conn),
      {:ok, post} <- get_post(post_id),
      :ok <- Bodyguard.permit(Timeline, :delete_post, user, post),
      {:ok, _deleted_post} <- delete_post(post)
    ) do
      put_status(conn, 204)
    end
  end
end
