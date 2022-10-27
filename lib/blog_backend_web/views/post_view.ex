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

  def render("create.json", %{status: 201, post: %Post{} = post}) do
    %{
      message: "Postagem realizada",
      post: render("post.json", post: post)
    }
  end

  def render("create.json", %{status: 422, changeset: %Ecto.Changeset{} = changeset}) do
    render(ErrorView, "error.json",
      changeset: changeset,
      message: "Não conseguimos realizar esta postagem"
    )
  end

  def render("show.json", %{status: 200, post: %Post{} = post}) do
    %{
      message: "Postagem encontrada",
      post: render("post.json", post: post)
    }
  end

  def render("show.json", %{status: 404}) do
    render(ErrorView, "error.json", message: "Não conseguimos realizar esta postagem")
  end

  def render("delete.json", %{status: 200, post: %Post{} = post}) do
    %{
      message: "Postagem deletada",
      post: render("post.json", post: post)
    }
  end

  def render("delete.json", %{status: 404}) do
    render(ErrorView, "error.json", message: "Não conseguimos localizar e deletar esta postagem")
  end
end
