defmodule BlogBackendWeb.CommentController do
  use BlogBackendWeb, :controller

  import BlogBackend.{Auth, Timeline}

  alias BlogBackend.Timeline
  alias BlogBackendWeb.FallbackController

  action_fallback FallbackController

  @spec index(Plug.Conn.t(), map) :: FallbackController.t()
  def index(conn, %{"user_id" => id}) do
    with(
      {:ok, user} <- get_user(id),
      comments <- list_user_comments(user)
    ) do
      render(conn, "index.json", comments: comments)
    end
  end

  def index(conn, %{"post_id" => id}) do
    with(
      {:ok, post} <- get_post(id),
      comments <- list_comments(post)
    ) do
      render(conn, "index.json", comments: comments)
    end
  end

  def index(conn, %{"comment_id" => id}) do
    with(
      {:ok, comment} <- get_comment(id),
      comments <- list_comments(comment)
    ) do
      render(conn, "index.json", comments: comments)
    end
  end

  @spec metrics(Plug.Conn.t(), map) :: FallbackController.t()
  def metrics(conn, %{"id" => id}) do
    with(
      {:ok, comment} <- get_comment(id),
      metrics <- get_metrics(comment)
    ) do
      conn
      |> render("metrics.json", metrics)
    end
  end

  @spec create(Plug.Conn.t(), map) :: FallbackController.t()
  def create(conn, %{"post_id" => father_id, "comment" => params}) do
    with(
      {:ok, user} <- get_athenticated_user(conn),
      {:ok, comment} <-
        params
        |> Map.merge(%{"user_id" => user.id, "post_id" => father_id})
        |> create_comment()
    ) do
      conn
      |> put_status(201)
      |> render("id.json", comment: comment)
    end
  end

  def create(conn, %{"comment_id" => father_id, "comment" => params}) do
    with(
      {:ok, user} <- get_athenticated_user(conn),
      {:ok, comment} <-
        params
        |> Map.merge(%{"user_id" => user.id, "comment_id" => father_id})
        |> create_comment()
    ) do
      conn
      |> put_status(201)
      |> render("id.json", comment: comment)
    end
  end

  @spec show(Plug.Conn.t(), map) :: FallbackController.t()
  def show(conn, %{"id" => id}) do
    with {:ok, comment} <- get_comment(id) do
      render(conn, "show.json", comment: comment)
    end
  end

  @spec delete(Plug.Conn.t(), map) :: FallbackController.t()
  def delete(conn, %{"id" => id}) do
    with(
      {:ok, user} <- get_athenticated_user(conn),
      {:ok, comment} <- get_comment(id),
      :ok <- Bodyguard.permit(Timeline, :delete_comment, user, comment),
      {:ok, _deleted_comment} <- Timeline.delete_comment(comment)
    ) do
      send_resp(conn, 204, "")
    end
  end
end
