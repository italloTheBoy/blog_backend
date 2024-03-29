defmodule BlogBackendWeb.PostViewTest do
  use BlogBackendWeb.ConnCase, async: true

  import BlogBackend.TimelineFixtures

  alias Phoenix.View
  alias BlogBackendWeb.PostView

  @moduletag :post_view

  @post_fields [:id, :user_id, :title, :body]

  setup do: {:ok, post: post_fixture()}

  @tag post_view: "index"
  test "renders index.json", %{post: post} do
    assert %{
             data: %{
               posts: [take_post(post)]
             }
           } == View.render(PostView, "index.json", posts: [post])
  end

  @tag post_view: "id"
  test "renders id.json", %{post: post} do
    assert %{data: take_post(post, [:id])} ==
             View.render(PostView, "id.json", post: post)
  end

  @tag post_view: "show"
  test "renders show.json", %{post: post} do
    assert %{
             data: %{post: take_post(post)}
           } == View.render(PostView, "show.json", post: post)
  end

  @tag post_view: "metrics"
  test "renders metrics.json" do
    likes = System.unique_integer([:positive])
    dislikes = System.unique_integer([:positive])
    comments = System.unique_integer([:positive])

    reactions = likes + dislikes

    metrics = %{
      reactions: reactions,
      likes: likes,
      dislikes: dislikes,
      comments: comments
    }

    assert %{
             data: metrics
           } == View.render(PostView, "metrics.json", metrics)
  end

  describe "renders post.json" do
    @tag post_view: "post"
    test "with no option render all fields", %{post: post} do
      assert take_post(post) ==
               View.render(PostView, "post.json", post: post)
    end

    @tag post_view: "post"
    test "with :only option renders only slected fields", %{post: post} do
      selected_fields = select_random_fields(@post_fields)

      assert take_post(post, selected_fields) ==
               View.render(PostView, "post.json",
                 post: post,
                 only: selected_fields
               )
    end
  end

  defp take_post(post, selected_fields \\ @post_fields)
       when is_list(selected_fields),
       do: Map.take(post, selected_fields)
end
