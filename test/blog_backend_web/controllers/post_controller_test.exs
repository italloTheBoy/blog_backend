defmodule BlogBackendWeb.PostControllerTest do
  use BlogBackendWeb.ConnCase, async: true

  import BlogBackend.AuthFixtures
  import BlogBackend.TimelineFixtures

  alias BlogBackendWeb.PostView

  @moduletag :post_controller

  @create_attrs %{
    title: "some title",
    body: "some body"
  }

  @invalid_attrs %{title: nil, body: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index user posts" do
    setup [:login, :create_post]

    @tag post_controller: "index_user_post"
    test "GET /api/user/:user_id/comments renders all user posts", %{
      conn: conn,
      user: user,
      post: post
    } do
      conn = get(conn, Routes.user_post_path(conn, :index, user.id))

      assert render(PostView, "index.json", posts: [post]) == json_response(conn, 200)
    end

    @tag post_controller: "index_user_post"
    test "GET /api/user/:user_id/comments with unexistent user_id renders an error", %{conn: conn} do
      conn = get(conn, Routes.user_post_path(conn, :index, 0))

      assert %{"detail" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag post_controller: "index_user_post"
    test "GET /api/user/:user_id/comments with invalid id renders an error", %{conn: conn} do
      conn = get(conn, Routes.user_post_path(conn, :index, "invalid_id"))

      assert %{"detail" => "Unprocessable Entity"} == json_response(conn, 422)["errors"]
    end
  end

  describe "create post" do
    setup [:login]

    @tag post_controller: "create_post"
    test "POST /api/post with valid data create a post and render his id", %{
      conn: conn,
      user: user
    } do
      conn = post(conn, Routes.post_path(conn, :create), post: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.post_path(conn, :show, id))

      assert %{
               "id" => id,
               "user_id" => user.id,
               "body" => @create_attrs.body
             } == json_response(conn, 200)["data"]["post"]
    end

    @tag post_controller: "create_post"
    test "POST /api/post with invalid data renders an error", %{conn: conn} do
      conn = post(conn, Routes.post_path(conn, :create), post: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show post" do
    setup [:create_post]

    @tag post_controller: "show_post"
    test "GET /api/post/:id with existent id renders a post", %{conn: conn, post: post} do
      conn = get(conn, Routes.post_path(conn, :show, post.id))
      assert render(PostView, "show.json", post: post) == json_response(conn, 200)
    end

    @tag post_controller: "show_post"
    test "GET /api/post/:id with nonexistent id renders an error", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :show, 0))

      assert %{"detail" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag post_controller: "show_post"
    test "GET /api/post/:id with invalid id renders an error", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :show, "invalid_id"))

      assert %{"detail" => "Unprocessable Entity"} == json_response(conn, 422)["errors"]
    end
  end

  describe "delete post" do
    setup [:login, :create_post]

    @tag post_controller: "delete_post"
    test "DELETE /api/post/:id with existent id delete a post", %{conn: conn, post: post} do
      conn = delete(conn, Routes.post_path(conn, :delete, post.id))
      assert response(conn, 204)

      conn = get(conn, Routes.post_path(conn, :show, post.id))
      assert %{"detail" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag post_controller: "delete_post"
    test "DELETE /api/post/:id with nonexistent id renders an error", %{conn: conn} do
      conn = delete(conn, Routes.post_path(conn, :delete, 0))

      assert %{"detail" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag post_controller: "delete_post"
    test "DELETE /api/post/:id with invalid id renders an error", %{conn: conn} do
      conn = delete(conn, Routes.post_path(conn, :delete, "invalid_id"))

      assert %{"detail" => "Unprocessable Entity"} == json_response(conn, 422)["errors"]
    end
  end

  defp create_post(%{user: user}),
    do: %{post: post_fixture(%{user_id: user.id})}

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
