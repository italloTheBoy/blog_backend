defmodule BlogBackendWeb.CommentControllerTest do
  use BlogBackendWeb.ConnCase, async: true

  import BlogBackend.{AuthFixtures, TimelineFixtures}

  alias BlogBackend.Timeline.Comment
  alias BlogBackendWeb.CommentView

  @moduletag :comment_controller

  @create_attrs %{body: "some body"}
  @update_attrs %{body: "some updated body"}
  @invalid_attrs %{body: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index user comments" do
    @tag comment_controller: "index_user_comments"
    test "GET /api/user/:user_id/comments list all user comments", %{conn: conn} do
      user = user_fixture()
      comment = comment_fixture(%{user_id: user.id, father: :post})

      conn = get(conn, Routes.user_comment_path(conn, :index, user.id))

      expected_res = render(CommentView, "index.json", comments: [comment])
      assert expected_res == json_response(conn, 200)
    end

    @tag comment_controller: "index_user_comments"
    test "GET /api/user/:user_id/comments when user not fouded, render an error", %{conn: conn} do
      conn = get(conn, Routes.user_comment_path(conn, :index, 0))

      assert %{"message" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag comment_controller: "index_user_comments"
    test "GET /api/user/:user_id/comments when user id is invalid, render an error", %{conn: conn} do
      conn = get(conn, Routes.user_comment_path(conn, :index, "invalid_id"))

      assert %{"message" => "Unprocessable Entity"} == json_response(conn, 422)["errors"]
    end
  end

  describe "index post comments" do
    @tag comment_controller: "index_post_comments"
    test "GET /api/post/:post_id/comments list all post comments", %{conn: conn} do
      %Comment{post_id: father_id} = comment = comment_fixture()

      conn = get(conn, Routes.post_comment_path(conn, :index, father_id))

      expected_res = render(CommentView, "index.json", comments: [comment])
      assert expected_res = json_response(conn, 200)["data"]
    end

    @tag comment_controller: "index_post_comments"
    test "GET /api/post/:post_id/comments when post not fouded, render an error", %{conn: conn} do
      conn = get(conn, Routes.post_comment_path(conn, :index, 0))

      assert %{"message" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag comment_controller: "index_post_comments"
    test "GET /api/post/:post_id/comments when post_id is invalid, render an error", %{conn: conn} do
      conn = get(conn, Routes.post_comment_path(conn, :index, "invalid_id"))

      assert %{"message" => "Unprocessable Entity"} == json_response(conn, 422)["errors"]
    end
  end

  describe "index comment comments" do
    @tag comment_controller: "index_comment_comments"
    test "GET /api/comment/:comment_id/comments list all post comments", %{conn: conn} do
      %Comment{comment_id: father_id} = comment = comment_fixture(%{father: :comment})

      conn = get(conn, Routes.comment_comment_path(conn, :index, father_id))

      expected_res = render(CommentView, "index.json", comments: [comment])
      assert expected_res = json_response(conn, 200)["data"]
    end

    @tag comment_controller: "index_comment_comments"
    test "GET /comment/:comment_id/comments when post not fouded, render an error", %{conn: conn} do
      conn = get(conn, Routes.comment_comment_path(conn, :index, 0))

      assert %{"message" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag comment_controller: "index_comment_comments"
    test "GET /comment/:comment_id/comments when post_id is invalid, render an error", %{
      conn: conn
    } do
      conn = get(conn, Routes.comment_comment_path(conn, :index, "invalid_id"))

      assert %{"message" => "Unprocessable Entity"} == json_response(conn, 422)["errors"]
    end
  end

  describe "create post comment" do
    setup [:create_comment, :create_post, :login]

    @tag comment_controller: "create_post_comment"
    test "POST /api/post/:post_id/comment with valid data comment a post", %{
      conn: conn,
      user: user,
      post: post
    } do
      conn = post(conn, Routes.post_comment_path(conn, :create, post.id), comment: @create_attrs)
      %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.comment_path(conn, :show, id))

      assert %{
               "id" => id,
               "user_id" => user.id,
               "post_id" => post.id,
               "comment_id" => nil,
               "body" => @create_attrs.body
             } == json_response(conn, 200)["data"]
    end

    @tag comment_controller: "create_post_comment"
    test "POST /api/post/:post_id/comment with invalid data render an error", %{conn: conn} do
      conn = post(conn, Routes.post_comment_path(conn, :create, 0), comment: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "create comment comment" do
    setup [:create_comment, :create_post, :login]

    @tag comment_controller: "create_comment_comment"
    test "POST /api/comment/:comment_id/comment with valid data comment a post", %{
      conn: conn,
      user: user,
      comment: comment
    } do
      conn =
        post(conn, Routes.comment_comment_path(conn, :create, comment.id), comment: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.comment_path(conn, :show, id))

      assert %{
               "id" => id,
               "user_id" => user.id,
               "post_id" => nil,
               "comment_id" => comment.id,
               "body" => @create_attrs.body
             } == json_response(conn, 200)["data"]
    end

    @tag comment_controller: "create_comment_comment"
    test "POST /api/comment/:comment_id/comment with invalid data render an error", %{conn: conn} do
      conn = post(conn, Routes.comment_comment_path(conn, :create, 0), comment: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show comment" do
    setup [:create_comment]

    @tag comment_controller: "show_comment"
    test "GET /api/comment/:id whith valid id render his comment", %{
      conn: conn,
      comment: comment
    } do
      conn = get(conn, Routes.comment_path(conn, :show, comment.id))

      assert render(CommentView, "show.json", comment: comment) == json_response(conn, 200)
    end

    @tag comment_controller: "show_comment"
    test "GET /api/comment/:id when comment can not be founded renders an error", %{conn: conn} do
      conn = get(conn, Routes.comment_path(conn, :show, 0))

      assert %{"message" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag comment_controller: "show_comment"
    test "GET /api/comment/:id with invalid id renders an error", %{conn: conn} do
      conn = get(conn, Routes.comment_path(conn, :show, "invalid_id"))

      assert %{"message" => "Unprocessable Entity"} == json_response(conn, 422)["errors"]
    end
  end

  describe "delete comment" do
    setup [:login, :create_comment]

    @tag comment_controller: "delete_comment"
    test "DELETE /api/comment/:id with valid id delete the repective comment", %{
      conn: conn,
      comment: comment
    } do
      conn = get(conn, Routes.comment_path(conn, :show, comment))
      assert %{} != json_response(conn, 200)

      conn = delete(conn, Routes.comment_path(conn, :delete, comment.id))

      conn = get(conn, Routes.comment_path(conn, :show, comment))
      assert %{"message" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag comment_controller: "delete_comment"
    test "DELETE /api/comment/:id when comment con not be founded render an error", %{conn: conn} do
      conn = get(conn, Routes.comment_path(conn, :show, 0))
      assert %{"message" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag comment_controller: "delete_comment"
    test "DELETE /api/comment/:id with invalid id render an error", %{conn: conn} do
      conn = get(conn, Routes.comment_path(conn, :show, "invalid_id"))
      assert %{"message" => "Unprocessable Entity"} == json_response(conn, 422)["errors"]
    end
  end

  defp create_comment(%{user: user}),
    do: %{
      comment: comment_fixture(%{user_id: user.id, father: :post})
    }

  defp create_comment(_), do: %{comment: comment_fixture()}

  defp create_post(%{user: user}),
    do: %{
      comment: post_fixture(%{user_id: user.id, father: :post})
    }

  defp create_post(_), do: %{post: post_fixture()}

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
