defmodule BlogBackendWeb.CommentView do
  use BlogBackendWeb, :view

  alias BlogBackendWeb.CommentView

  def render("show.json", %{comment: comment, message: message}) do
    %{
      message: message,
      data: render_one(comment, CommentView, "comment.json")
    }
  end

  def render("show.json", %{comment: comment}) do
    %{
      message: "OK",
      data: render_one(comment, CommentView, "comment.json")
    }
  end

  def render("delete.json", _assigns) do
    %{message: "OK"}
  end

  def render("comment.json", %{comment: comment}) do
    Map.take(
      comment,
      [:id, :user_id, :post_id, :comment_id, :body, :inserted_at, :updated_at]
    )
  end
end
