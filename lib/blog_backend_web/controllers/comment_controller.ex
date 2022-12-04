defmodule BlogBackendWeb.CommentController do
  use BlogBackendWeb, :controller

  alias Phoenix.LiveView.Plug
  alias BlogBackend.{Auth, Timeline}
  alias BlogBackend.Auth.User
  alias BlogBackend.Timeline.Comment

  action_fallback BlogBackendWeb.FallbackController

  @spec create(Plug.Conn.t(), map) :: BlogBackendWeb.FallbackController.t()
  def create(conn, params) do
    with(
      {:ok, %User{} = user} <- Auth.get_current_user(conn),
      :ok <- Bodyguard.permit(Timeline, :create_comment, user),
      create_attrs <- Map.merge(params, %{"user_id" => user.id}),
      {:ok, %Comment{} = comment} <- Timeline.create_comment(create_attrs)
    ) do
      conn
      |> put_status(201)
      |> put_resp_header("location", Routes.comment_path(conn, :show, comment))
      |> render("show.json", comment: comment, message: "Created")
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
      {:ok, %User{} = user} <- Auth.get_current_user(conn),
      {:ok, %Comment{} = comment} <- Timeline.get_comment(id),
      :ok <- Bodyguard.permit(Timeline, :delete_comment, user, comment),
      {:ok, %Comment{}} <- Timeline.delete_comment(comment)
    ) do
      render(conn, "delete.json", [])
    end
  end
end
