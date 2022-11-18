defmodule BlogBackendWeb.CommentController do
  use BlogBackendWeb, :controller

  alias Phoenix.LiveView.Plug
  alias BlogBackend.Timeline
  alias BlogBackend.Timeline.Comment

  action_fallback BlogBackendWeb.FallbackController

  @spec create(Plug.Conn.t(), map) :: BlogBackendWeb.FallbackController.t()
  def create(conn, params) do
    with {:ok, %Comment{} = comment} <- Timeline.create_comment(params) do
      conn
      |> put_status(201)
      |> put_resp_header("location", Routes.comment_path(conn, :show, comment))
      |> render("show.json", comment: comment)
    end
  end

  @spec show(Plug.Conn.t(), map) :: BlogBackendWeb.FallbackController.t()
  def show(conn, %{"id" => id}) do
    with {:ok, %Comment{} = comment} <- Timeline.get_comment(id) do
      render(conn, "show.json", comment: comment)
    end
  end

  @spec delete(Plug.Conn.t(), map) :: BlogBackendWeb.FallbackController.t()
  def delete(conn, %{"id" => id}) do
    with(
      {:ok, %Comment{} = comment} <- Timeline.get_comment(id),
      {:ok, %Comment{}} <- Timeline.delete_comment(comment)
    ) do
      render(conn, "delete.josn")
    end
  end
end
