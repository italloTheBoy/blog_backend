defmodule BlogBackendWeb.ReactionControllerTest do
  use BlogBackendWeb.ConnCase, async: true

  import BlogBackend.{AuthFixtures, TimelineFixtures}

  alias BlogBackend.Timeline.Reaction
  alias BlogBackendWeb.ReactionView

  @moduletag :reaction_controller

  @create_attrs %{type: random_reaction_type()}
  @invalid_attrs %{type: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index user reactions" do
    setup [:create_reaction]

    @tag reaction_controller: "index_user_reactions"
    test "renders user all reactions", %{
      conn: conn,
      reaction: %Reaction{user_id: user_id} = reaction
    } do
      conn = get(conn, Routes.user_reaction_path(conn, :index, user_id))

      expected_response = render(ReactionView, "index.json", reactions: [reaction])
      assert expected_response == json_response(conn, 200)
    end

    @tag reaction_controller: "index_user_reactions"
    test "renders an error when user cant be found", %{conn: conn} do
      conn = get(conn, Routes.user_reaction_path(conn, :index, 0))

      assert %{"detail" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag reaction_controller: "index_user_reactions"
    test "whith invalid data renders an error", %{conn: conn} do
      conn = get(conn, Routes.user_reaction_path(conn, :index, "invalid"))

      assert %{"detail" => "Unprocessable Entity"} == json_response(conn, 422)["errors"]
    end
  end

  describe "create post reaction" do
    setup [:create_post, :login]

    @tag reaction_controller: "create_post_reaction"
    test "create an reaction and renders his id", %{
      conn: conn,
      user: user,
      post: post
    } do
      conn =
        post(conn, Routes.post_reaction_path(conn, :create, post.id), reaction: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.reaction_path(conn, :show, id))

      assert %{
               "id" => id,
               "user_id" => user.id,
               "post_id" => post.id,
               "comment_id" => nil,
               "type" => @create_attrs.type
             } == json_response(conn, 200)["data"]["reaction"]
    end

    @tag reaction_controller: "create_post_reaction"
    test "when reaction already exists renders an error", %{
      conn: conn,
      post: post
    } do
      create = fn ->
        post(conn, Routes.post_reaction_path(conn, :create, post.id), reaction: @create_attrs)
      end

      create.()
      conn = create.()

      assert %{"user_id" => ["A reação ja existe"]} == json_response(conn, 422)["errors"]
    end

    @tag reaction_controller: "create_post_reaction"
    test "with invalid data renders errors", %{conn: conn} do
      conn =
        post(conn, Routes.post_reaction_path(conn, :create, "invalid"), reaction: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "create comment reaction" do
    setup [:create_comment, :login]

    @tag reaction_controller: "create_comment_reaction"
    test "create an reaction and renders his id", %{
      conn: conn,
      user: user,
      comment: comment
    } do
      conn =
        post(conn, Routes.comment_reaction_path(conn, :create, comment.id),
          reaction: @create_attrs
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.reaction_path(conn, :show, id))

      assert %{
               "id" => id,
               "user_id" => user.id,
               "post_id" => nil,
               "comment_id" => comment.id,
               "type" => @create_attrs.type
             } == json_response(conn, 200)["data"]["reaction"]
    end

    @tag reaction_controller: "create_post_reaction"
    test "when reaction already exists renders an error", %{
      conn: conn,
      comment: comment
    } do
      create = fn ->
        post(conn, Routes.comment_reaction_path(conn, :create, comment.id),
          reaction: @create_attrs
        )
      end

      create.()
      conn = create.()

      assert %{"user_id" => ["A reação ja existe"]} == json_response(conn, 422)["errors"]
    end

    @tag reaction_controller: "create_post_reaction"
    test "with invalid data renders errors", %{conn: conn} do
      conn =
        post(conn, Routes.comment_reaction_path(conn, :create, "invalid"),
          reaction: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show reaction" do
    setup [:login, :create_reaction]

    @tag reaction_controller: "show_reaction"
    test "fetches and render an reaction", %{
      conn: conn,
      reaction: reaction
    } do
      conn = get(conn, Routes.reaction_path(conn, :show, reaction.id))

      assert render(ReactionView, "show.json", reaction: reaction) == json_response(conn, 200)
    end

    @tag reaction_controller: "show_reaction"
    test "when reaction cant be finded renders an error", %{
      conn: conn
    } do
      conn = get(conn, Routes.reaction_path(conn, :show, 0))

      assert %{"detail" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag reaction_controller: "show_reaction"
    test "with invalid data rebders an error", %{conn: conn} do
      conn = get(conn, Routes.reaction_path(conn, :show, "invalid"))

      assert %{"detail" => "Unprocessable Entity"} == json_response(conn, 422)["errors"]
    end
  end

  describe "show reaction by user and post" do
    setup [:login, :create_post, :create_reaction]

    @tag reaction_controller: "show_user_post_reaction"
    test "fetches and render an reaction", %{
      conn: conn,
      post: post,
      reaction: reaction
    } do
      conn = get(conn, Routes.post_reaction_path(conn, :show, post.id))

      assert render(ReactionView, "show.json", reaction: reaction) == json_response(conn, 200)
    end

    @tag reaction_controller: "show_user_post_reaction"
    test "when reaction cant be finded renders an error", %{conn: conn} do
      conn = get(conn, Routes.post_reaction_path(conn, :show, 0))

      assert %{"detail" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag reaction_controller: "show_user_post_reaction"
    test "with invalid data rebders an error", %{conn: conn} do
      conn = get(conn, Routes.post_reaction_path(conn, :show, "invalid"))

      assert %{"detail" => "Unprocessable Entity"} == json_response(conn, 422)["errors"]
    end
  end

  describe "show reaction by user and comment" do
    setup [:login, :create_comment, :create_reaction]

    @tag reaction_controller: "show_user_comment_reaction"
    test "fetches and render an reaction", %{
      conn: conn,
      comment: comment,
      reaction: reaction
    } do
      conn = get(conn, Routes.comment_reaction_path(conn, :show, comment.id))

      assert render(ReactionView, "show.json", reaction: reaction) == json_response(conn, 200)
    end

    @tag reaction_controller: "show_user_comment_reaction"
    test "when reaction cant be finded renders an error", %{conn: conn} do
      conn = get(conn, Routes.comment_reaction_path(conn, :show, 0))

      assert %{"detail" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag reaction_controller: "show_user_comment_reaction"
    test "with invalid data rebders an error", %{conn: conn} do
      conn = get(conn, Routes.comment_reaction_path(conn, :show, "invalid"))

      assert %{"detail" => "Unprocessable Entity"} == json_response(conn, 422)["errors"]
    end
  end

  describe "update reaction" do
    setup [:login, :create_reaction]

    @tag reaction_controller: "update_reaction"
    test "updates the chosen reaction type", %{
      conn: conn,
      reaction: reaction
    } do
      toggle_reaction_type = fn
        "like" -> "dislike"
        "dislike" -> "like"
      end

      conn = put(conn, Routes.reaction_path(conn, :update, reaction.id))

      assert %{"id" => reaction.id} == json_response(conn, 200)["data"]

      conn = get(conn, Routes.reaction_path(conn, :show, reaction.id))

      assert toggle_reaction_type.(reaction.type) ==
               json_response(conn, 200)["data"]["reaction"]["type"]
    end

    @tag reaction_controller: "update_reaction"
    test "renders an error when reaction cant be finded", %{conn: conn} do
      conn = put(conn, Routes.reaction_path(conn, :update, 0))

      assert %{"detail" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag reaction_controller: "update_reaction"
    test "whith invalid id renders an error", %{conn: conn} do
      conn = put(conn, Routes.reaction_path(conn, :update, "invalid"))

      assert %{"detail" => "Unprocessable Entity"} == json_response(conn, 422)["errors"]
    end
  end

  describe "delete reaction" do
    setup [:login, :create_reaction]

    @tag reaction_controller: "delete_reaction"
    test "deletes chosen reaction", %{
      conn: conn,
      reaction: reaction
    } do
      conn = delete(conn, Routes.reaction_path(conn, :delete, reaction.id))
      assert response(conn, 204)

      conn = get(conn, Routes.reaction_path(conn, :show, reaction))
      assert %{"detail" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag reaction_controller: "delete_reaction"
    test "when reaction cant be founded renders an error", %{conn: conn} do
      conn = delete(conn, Routes.reaction_path(conn, :delete, 0))

      assert %{"detail" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag reaction_controller: "delete_reaction"
    test "with invalid data renders an error", %{conn: conn} do
      conn = delete(conn, Routes.reaction_path(conn, :delete, "invalid"))

      assert %{"detail" => "Unprocessable Entity"} == json_response(conn, 422)["errors"]
    end
  end

  describe "post reactions metrics" do
    setup [:create_post]

    @tag reaction_controller: "post_reactions_metrics"
    test "with post id render reactions his metrics", %{
      conn: conn,
      post: post
    } do
      conn = get(conn, Routes.post_reaction_path(conn, :metrics, post.id))
      assert json_response(conn, 200)
    end

    @tag reaction_controller: "post_reactions_metrics"
    test "with inexistent id render renders an error", %{conn: conn} do
      conn = get(conn, Routes.post_reaction_path(conn, :metrics, 0))
      assert json_response(conn, 404)
    end

    @tag reaction_controller: "post_reactions_metrics"
    test "with invalid id render renders an error", %{conn: conn} do
      conn = get(conn, Routes.post_reaction_path(conn, :metrics, "invalid"))
      assert json_response(conn, 422)
    end
  end

  describe "comment reactions metrics" do
    setup [:create_comment]

    @tag reaction_controller: "comment_reactions_metrics"
    test "with comment id render reactions his metrics", %{
      conn: conn,
      comment: comment
    } do
      conn = get(conn, Routes.comment_reaction_path(conn, :metrics, comment.id))
      assert json_response(conn, 200)
    end

    @tag reaction_controller: "comment_reactions_metrics"
    test "with inexistent id render renders an error", %{conn: conn} do
      conn = get(conn, Routes.comment_reaction_path(conn, :metrics, 0))
      assert json_response(conn, 404)
    end

    @tag reaction_controller: "comment_reactions_metrics"
    test "with invalid id render renders an error", %{conn: conn} do
      conn = get(conn, Routes.comment_reaction_path(conn, :metrics, "invalid"))
      assert json_response(conn, 422)
    end
  end

  defp create_comment(%{user: user}),
    do: %{
      comment: comment_fixture(%{user_id: user.id, father: :post})
    }

  defp create_comment(_),
    do: %{
      comment: comment_fixture()
    }

  defp create_post(%{user: user}),
    do: %{
      post: post_fixture(%{user_id: user.id, father: :post})
    }

  defp create_post(_),
    do: %{
      post: post_fixture()
    }

  defp create_reaction(%{user: user, post: post}),
    do: %{
      reaction:
        reaction_fixture(%{
          father: :post,
          user_id: user.id,
          post_id: post.id
        })
    }

  defp create_reaction(%{user: user, comment: comment}),
    do: %{
      reaction:
        reaction_fixture(%{
          father: :comment,
          user_id: user.id,
          comment_id: comment.id
        })
    }

  defp create_reaction(%{post: post}),
    do: %{
      reaction:
        reaction_fixture(%{
          father: :post,
          post_id: post.id
        })
    }

  defp create_reaction(%{comment: comment}),
    do: %{
      reaction:
        reaction_fixture(%{
          father: :comment,
          comment_id: comment.id
        })
    }

  defp create_reaction(%{user: user}),
    do: %{
      reaction:
        reaction_fixture(%{
          user_id: user.id,
          father: :post
        })
    }

  defp create_reaction(_),
    do: %{
      reaction: reaction_fixture()
    }

  defp login(%{conn: conn, user: user}) do
    token = token_fixture(user)
    conn = put_req_header(conn, "authorization", token)

    %{conn: conn, user: user, token: token}
  end

  defp login(%{conn: conn}) do
    user = user_fixture()
    token = token_fixture(user)

    conn = put_req_header(conn, "authorization", token)

    %{conn: conn, user: user, token: token}
  end
end
