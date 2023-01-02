defmodule BlogBackendWeb.CommentView do
  use BlogBackendWeb, :view

  @comment_fields [
    :id,
    :user_id,
    :post_id,
    :comment_id,
    :body,
  ]

  def render("index.json", %{comments: comments}),
    do: %{
      data: render_many(comments, __MODULE__, "comment.json")
    }

  def render("id.json", %{comment: comment}),
    do: %{
      data: render("comment.json", comment: comment, only: [:id])
    }

  def render("show.json", %{comment: comment}),
    do: %{
      data: render("comment.json", comment: comment)
    }

  def render("comment.json", %{comment: comment, only: selected_fields})
      when is_list(selected_fields),
      do: Map.take(comment, selected_fields)

  def render("comment.json", %{comment: comment}), do: Map.take(comment, @comment_fields)
end
