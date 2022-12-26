defmodule BlogBackendWeb.PostView do
  use BlogBackendWeb, :view

  alias BlogBackend.Timeline.Post
  alias BlogBackendWeb.PostView

  def render("create.json", %{post: %Post{id: id}}),
    do: render("create.json", post_id: id)

  def render("create.json", %{post_id: id}),
    do: %{data: %{id: id}}

  def render("index.json", %{posts: posts}),
    do: %{data: render_many(posts, PostView, "post.json")}

  def render("show.json", %{post: %Post{} = post}),
    do: %{data: render("post.json", post: post)}

  def render("post.json", %{post: %Post{} = post}),
    do:
      Map.take(
        post,
        [:id, :title, :body, :inserted_at, :updated_at]
      )
end
