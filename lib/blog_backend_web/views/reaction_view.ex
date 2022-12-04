defmodule BlogBackendWeb.ReactionView do
  use BlogBackendWeb, :view
  alias BlogBackendWeb.ReactionView

  def render("show.json", %{reaction: reaction, message: message}) do
    %{
      message: message,
      data: render_one(reaction, ReactionView, "reaction.json")
    }
  end

  def render("show.json", %{reaction: reaction}) do
    %{
      message: "OK",
      data: render_one(reaction, ReactionView, "reaction.json")
    }
  end

  def render("reaction.json", %{reaction: reaction}) do
    Map.take(
      reaction,
      [:id, :user_id, :post_id, :comment_id, :type, :inserted_at, :updated_at]
    )
  end
end
