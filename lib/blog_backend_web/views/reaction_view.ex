defmodule BlogBackendWeb.ReactionView do
  alias BlogBackend.Timeline.Reaction
  use BlogBackendWeb, :view

  @reaction_fields [
    :id,
    :user_id,
    :post_id,
    :comment_id,
    :type
  ]

  def render("index.json", %{reactions: reactions})
      when is_list(reactions),
      do: %{
        data: %{reactions: render_many(reactions, __MODULE__, "reaction.json")}
      }

  def render("id.json", %{reaction: %Reaction{} = reaction}),
    do: %{
      data: %{id: reaction.id}
    }

  def render("show.json", %{reaction: %Reaction{} = reaction}),
    do: %{
      data: %{reaction: render("reaction.json", reaction: reaction)}
    }

  def render("metrics.json", %{
        reactions: reactions,
        likes: likes,
        dislikes: dislikes
      })
      when is_integer(reactions) and is_integer(likes) and is_integer(dislikes),
      do: %{
        data: %{
          reactions: reactions,
          likes: likes,
          dislikes: dislikes
        }
      }

  def render("reaction.json", %{reaction: %Reaction{} = reaction, only: selected_fields})
      when is_list(selected_fields),
      do: Map.take(reaction, selected_fields)

  def render("reaction.json", %{reaction: %Reaction{} = reaction}),
    do: Map.take(reaction, @reaction_fields)
end
