defmodule BlogBackendWeb.CommentView do
  use BlogBackendWeb, :view

  @metrics_fields [:commets, :reactions, :likes, :dislikes]

  @comment_fields [
    :id,
    :user_id,
    :post_id,
    :comment_id,
    :body
  ]

  def render("index.json", %{comments: comments}),
    do: %{
      data: %{comments: render_many(comments, __MODULE__, "comment.json")}
    }

  def render("id.json", %{comment: comment}),
    do: %{
      data: %{id: comment.id}
    }

  def render("show.json", %{comment: comment}),
    do: %{
      data: %{comment: render("comment.json", comment: comment)}
    }

  def render(
        "metrics.json",
        %{
          reactions: _reactions,
          likes: _likes,
          dislikes: _dislikes,
          comments: _comments
        } = metrics
      ),
      do: %{data: Map.take(metrics, @metrics_fields)}

  def render("comment.json", %{comment: comment, only: selected_fields})
      when is_list(selected_fields),
      do: Map.take(comment, selected_fields)

  def render("comment.json", %{comment: comment}), do: Map.take(comment, @comment_fields)
end
