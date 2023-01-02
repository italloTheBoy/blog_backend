defmodule BlogBackendWeb.CommentViewTest do
  use BlogBackendWeb.ConnCase, async: true

  import BlogBackend.TimelineFixtures

  alias Phoenix.View
  alias BlogBackendWeb.CommentView

  @moduletag :comment_view

  @comment_fields [
    :id,
    :user_id,
    :post_id,
    :comment_id,
    :body
  ]

  setup do: {:ok, comment: comment_fixture()}

  @tag post_view: "index"
  test "renders index.json", %{comment: comment} do
    assert %{data: [take_comment(comment)]} ==
             View.render(CommentView, "index.json", comments: [comment])
  end

  @tag post_view: "id"
  test "renders id.json", %{comment: comment} do
    assert %{data: take_comment(comment, [:id])} ==
             View.render(CommentView, "id.json", comment: comment)
  end

  @tag post_view: "show"
  test "renders show.json", %{comment: comment} do
    assert %{data: take_comment(comment)} ==
             View.render(CommentView, "show.json", comment: comment)
  end

  describe "renders comment.json" do
    @tag post_view: "comment"
    test "with no option render all fields", %{comment: comment} do
      assert take_comment(comment) ==
               View.render(CommentView, "comment.json", comment: comment)
    end

    @tag post_view: "comment"
    test "with :only option renders only slected fields", %{comment: comment} do
      selected_fields = select_random_fields(@comment_fields)

      assert take_comment(comment, selected_fields) ==
               View.render(CommentView, "comment.json",
                 comment: comment,
                 only: selected_fields
               )
    end
  end

  defp take_comment(comment, selected_fields \\ @comment_fields)
       when is_list(selected_fields),
       do: Map.take(comment, selected_fields)
end
