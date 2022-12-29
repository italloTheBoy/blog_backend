defmodule BlogBackendWeb.PostView do
  use BlogBackendWeb, :view

  alias BlogBackend.Timeline.Post

  @post_fields [:id, :user_id, :title, :body]

  def render("create.json", %{post: %Post{id: id}}),
    do: render("create.json", post_id: id)

  def render("create.json", %{post_id: id}),
    do: %{data: %{id: id}}

  def render("index.json", %{posts: posts}),
    do: %{data: render_many(posts, __MODULE__, "post.json")}

  def render("show.json", %{post: post}),
    do: %{data: render("post.json", post: post)}

  def render("post.json", %{post: post, only: selected_fields})
      when is_list(selected_fields),
      do: Map.take(post, selected_fields)

  def render("post.json", %{post: post}),
    do: Map.take(post, @post_fields)
end
