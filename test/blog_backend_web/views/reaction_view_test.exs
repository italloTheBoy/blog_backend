defmodule BlogBackendWeb.ReactionViewTest do
  use BlogBackendWeb.ConnCase, async: true

  import BlogBackend.TimelineFixtures

  alias Phoenix.View
  alias BlogBackendWeb.ReactionView

  @moduletag :reaction_view

  @reaction_fields [
    :id,
    :user_id,
    :post_id,
    :comment_id,
    :type
  ]

  setup do: {:ok, reaction: reaction_fixture()}

  @tag reaction_view: "index"
  test("renders index.json", %{reaction: reaction},
    do:
      assert(
        View.render(ReactionView, "index.json", reactions: [reaction]) == %{
          data: [Map.take(reaction, @reaction_fields)]
        }
      )
  )

  @tag reaction_view: "id"
  test("renders id.json", %{reaction: reaction},
    do:
      assert(
        View.render(ReactionView, "id.json", reaction: reaction) == %{
          data: Map.take(reaction, [:id])
        }
      )
  )

  @tag reaction_view: "show"
  test("renders show.json", %{reaction: reaction},
    do:
      assert(
        View.render(ReactionView, "show.json", reaction: reaction) == %{
          data: Map.take(reaction, @reaction_fields)
        }
      )
  )

  describe "renders reaction.json" do
    @tag reaction_view: "reaction"
    test("whith any aption render all fields", %{reaction: reaction},
      do:
        assert(
          Map.take(reaction, @reaction_fields) ==
            View.render(ReactionView, "reaction.json", reaction: reaction)
        )
    )

    @tag reaction_view: "reaction"
    test "whith :only option renders only slected fields", %{reaction: reaction} do
      selected_fields =
        Enum.take_random(@reaction_fields, Enum.random(0..length(@reaction_fields)))

      assert Map.take(reaction, selected_fields) ==
               View.render(ReactionView, "reaction.json",
                 reaction: reaction,
                 only: selected_fields
               )
    end
  end
end
