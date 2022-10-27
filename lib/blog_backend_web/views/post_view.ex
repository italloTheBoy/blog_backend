defmodule BlogBackendWeb.PostView do
  use BlogBackendWeb, :view

  alias BlogBackend.Timeline.Post
  alias BlogBackendWeb.{ErrorView}

  def render("post.json", %{post: %Post{} = post}) do
    Map.take(
      post,
      [:id, :title, :body, :inserted_at, :updated_at]
    )
  end

  def render("create.json", %{status: 201, post: post}) do
    %{
      message: "Postagem feita",
      post: render("post.json", post: post)
    }
  end

  def render("create.json", %{status: 422, changeset: changeset}) do
    render(ErrorView, "changeset.json",
      changeset: changeset,
      message: "Não conseguimos realizar esta postagem"
    )
  end
end
