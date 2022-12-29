defmodule BlogBackendWeb.ReactionView do
  use BlogBackendWeb, :view

  @reaction_fields [
    :id,
    :user_id,
    :post_id,
    :comment_id,
    :type
  ]

  def render("index.json", %{reactions: reactions}),
    do: %{
      data: render_many(reactions, __MODULE__, "reaction.json")
    }

  def render("id.json", %{reaction: reaction}),
    do: %{
      data: render("reaction.json", reaction: reaction, only: [:id])
    }

  def render("show.json", %{reaction: reaction}),
    do: %{
      data: render("reaction.json", reaction: reaction)
    }

  def render("reaction.json", %{reaction: reaction, only: selected_fields})
      when is_list(selected_fields),
      do: Map.take(reaction, selected_fields)

  def render("reaction.json", %{reaction: reaction}),
    do: Map.take(reaction, @reaction_fields)
end
