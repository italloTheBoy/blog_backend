defmodule BlogBackendWeb.PostView do
  use BlogBackendWeb, :view
  alias BlogBackend.Timeline.Post

  def render("show.json", %{post: %Post{} = post, message: messsage}) do
    %{
      message: messsage,
      post: render("post.json", post: post)
    }
  end

  def render("show.json", %{post: %Post{} = post}) do
    %{
      message: "OK",
      post: render("post.json", post: post)
    }
  end

  def render("post.json", %{post: %Post{} = post}) do
    Map.take(
      post,
      [:id, :title, :body, :inserted_at, :updated_at]
    )
  end
end
