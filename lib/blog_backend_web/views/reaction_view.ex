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
    %{
      id: reaction.id,
      type: reaction.type
    }
  end
end
