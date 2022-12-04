defmodule BlogBackendWeb.PostController do
  use BlogBackendWeb, :controller

  import BlogBackend.{Auth, Timeline}

  alias BlogBackend.Timeline
  alias BlogBackend.Auth.User
  alias BlogBackend.Timeline.Post
  alias BlogBackendWeb.FallbackController

  action_fallback FallbackController

  @spec create(Plug.Conn.t(), map) :: FallbackController.t()
  def create(conn, params) do
    with(
      {:ok, %User{} = user} <- get_current_user(conn),
      :ok <- Bodyguard.permit(Timeline, :create_post, user),
      create_attrs <- Map.merge(params, %{"user_id" => user.id}),
      {:ok, %Post{} = post} <- create_post(create_attrs)
    ) do
      conn
      |> put_status(201)
      |> render("show.json", messaage: "Created", post: post)
    end
  end

  @spec show(Plug.Conn.t(), map) :: FallbackController.t()
  def show(conn, %{"id" => post_id}) do
    with {:ok, %Post{} = post} <- get_post(post_id) do
      render(conn, "show.json", post: post)
    end
  end

  @spec delete(Plug.Conn.t(), map) :: FallbackController.t()
  def delete(conn, %{"id" => post_id}) do
    with(
      {:ok, %User{} = user} <- get_current_user(conn),
      {:ok, %Post{} = post} <- get_post(post_id),
      :ok <- Bodyguard.permit(Timeline, :delete_post, user, post),
      {:ok, %Post{} = deleted_post} <- delete_post(post)
    ) do
      render(conn, "show.json", post: deleted_post)
    end
  end
end
