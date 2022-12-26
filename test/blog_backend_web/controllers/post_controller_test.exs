defmodule BlogBackendWeb.PostControllerTest do
  use BlogBackendWeb.ConnCase

  import BlogBackend.AuthFixtures
  import BlogBackend.TimelineFixtures

  alias Plug.Router
  alias BlogBackend.Timeline.Post

  @moduletag :post_controller

  @create_attrs %{
    title: "some title",
    body: "some body"
  }

  @update_attrs %{
    title: "some updated title",
    body: "some updated body"
  }

  @invalid_attrs %{title: nil, body: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create post" do
    setup [:login]

    @tag post_controller: "create_post"
    test "create a post and render his id", %{conn: conn} do
      conn = post(conn, Routes.post_path(conn, :create), post: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.post_path(conn, :show, id))
      post = json_response(conn, 200)["data"]

      assert post["id"] == id
      assert post["title"] == @create_attrs.title
      assert post["body"] == @create_attrs.body
    end

    @tag :create_post
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.post_path(conn, :create), post: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show post" do
    setup [:login, :create_post]

    @tag post_controller: "show_post"
    test "with existent id renders a post", %{conn: conn, post: post} do
      conn = get(conn, Routes.post_path(conn, :show, post.id))
      res = json_response(conn, 200)["data"]

      assert res["id"] == post.id
    end

    @tag post_controller: "show_post"
    test "with nonexistent id renders an error", %{conn: conn, post: post} do
      conn = delete(conn, Routes.post_path(conn, :delete, post.id))
      conn = get(conn, Routes.post_path(conn, :show, post.id))

      assert %{"message" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag post_controller: "show_post"
    test "with invalid id renders an error", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :show, "invalid_id"))

      assert %{"message" => "Unprocessable Entity"} == json_response(conn, 422)["errors"]
    end
  end

  describe "show user posts" do
    setup [:login, :create_post]

    @tag post_controller: "index_post"
    test "with existent id renders all user posts", %{
      conn: conn,
      user: user,
      post: post
    } do
      conn = get(conn, Routes.post_path(conn, :index, user.id))

      assert 1 == json_response(conn, 200)["data"] |> length()
    end

    @tag post_controller: "index_post"
    test "with existent id when user has any post renders empty data", %{
      conn: conn,
      user: user,
      post: post
    } do
      conn = delete(conn, Routes.post_path(conn, :delete, post.id))
      conn = get(conn, Routes.post_path(conn, :index, user.id))

      assert 0 == json_response(conn, 200)["data"] |> length()
    end

    @tag post_controller: "index_post"
    test "with unexistent id renders an error", %{
      conn: conn,
      user: user,
      post: post
    } do
      conn = delete(conn, Routes.user_path(conn, :delete, user.id))
      conn = get(conn, Routes.post_path(conn, :index, user.id))

      assert %{"message" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag post_controller: "index_post"
    test "with invalid id renders an error", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :index, "invalid_id"))

      assert %{"message" => "Unprocessable Entity"} == json_response(conn, 422)["errors"]
    end
  end

  describe "delete post" do
    setup [:login, :create_post]

    @tag post_controller: "delete_post"
    test "with existent id delete a post", %{conn: conn, post: post} do
      conn = delete(conn, Routes.post_path(conn, :delete, post.id))
      conn = get(conn, Routes.post_path(conn, :show, post.id))

      assert %{"message" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag post_controller: "delete_post"
    test "with nonexistent id renders an error", %{conn: conn, post: post} do
      conn = delete(conn, Routes.post_path(conn, :delete, post.id))
      conn = delete(conn, Routes.post_path(conn, :delete, post.id))

      assert %{"message" => "Not Found"} == json_response(conn, 404)["errors"]
    end

    @tag post_controller: "delete_post"
    test "with invalid id renders an error", %{conn: conn} do
      conn = delete(conn, Routes.post_path(conn, :delete, "invalid_id"))

      assert %{"message" => "Unprocessable Entity"} == json_response(conn, 422)["errors"]
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
