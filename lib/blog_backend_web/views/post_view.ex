defmodule BlogBackendWeb.PostView do
  use BlogBackendWeb, :view

  alias BlogBackend.Timeline.Post

  @post_fields [:id, :user_id, :body]
  @metrics_fields [:commets, :reactions, :likes, :dislikes]

  def render("id.json", %{post: %Post{} = post}),
    do: %{
      data: %{id: post.id}
    }

  def render("index.json", %{posts: posts}) when is_list(posts),
    do: %{
      data: %{posts: render_many(posts, __MODULE__, "post.json")}
    }

  def render("show.json", %{post: post}),
    do: %{
      data: %{post: render("post.json", post: post)}
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

  def render("post.json", %{post: post, only: selected_fields})
      when is_list(selected_fields),
      do: Map.take(post, selected_fields)

  def render("post.json", %{post: post}),
    do: Map.take(post, @post_fields)
end
