defmodule BlogBackendWeb.UserControllerTest do
  use BlogBackendWeb.ConnCase, async: true

  import BlogBackend.AuthFixtures

  alias BlogBackend.Auth
  alias BlogBackendWeb.UserView

  @moduletag :user_controller

  @create_attrs %{
    email: unique_user_email(),
    username: unique_user_username(),
    password: "password",
    password_confirmation: "password"
  }

  @update_attrs %{
    email: unique_user_email(),
    username: unique_user_username(),
    password: "password_updated",
    password_confirmation: "password_updated"
  }

  @invalid_attrs %{
    email: "invalid email",
    username: "invalid usermame",
    password: "long passssssssssssssssword",
    password_confirmation: "other password"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "user index" do
    setup [:create_user]

    @tag user_controller: "user_index"
    test "fecthes many users with given the data", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :index, false))
      assert [] == json_response(conn, 200)["data"]["users"]

      conn = get(conn, Routes.user_path(conn, :index, user.username))
      assert render(UserView, "index.json", users: [user]) == json_response(conn, 200)
    end
  end

  describe "user create" do
    @tag user_controller: "user_create"
    test "creates an user with the given data", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      show_view = render(UserView, "show.json", user: Auth.get_user!(id))
      conn = get(conn, Routes.user_path(conn, :show, id))
      assert show_view == json_response(conn, 200)
    end

    @tag user_controller: "user_create"
    test "with invalid data returns all errors", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert %{} != json_response(conn, 422)["errors"]
    end
  end

  describe "user show" do
    setup [:create_user]

    @tag user_controller: "user_show"
    test "fetches an user whith given id", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user.id))
      show_view = render(UserView, "show.json", user: user)
      assert show_view == json_response(conn, 200)
    end

    @tag user_controller: "user_show"
    test "when user cant be finded returns an error", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show, 0))
      assert json_response(conn, 404)
    end

    @tag user_controller: "user_show"
    test "with invalid id returns an error", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show, "invalid"))
      assert json_response(conn, 422)
    end
  end

  describe "user update" do
    setup [:login]

    @tag user_controller: "user_update"
    test "updates user with the given data", %{conn: conn, user: user} do
      conn = patch(conn, Routes.user_path(conn, :update, user.id), changes: @update_attrs)
      assert %{"id" => _id} = json_response(conn, 200)["data"]

      show_view = render(UserView, "show.json", user: Map.merge(user, @update_attrs))
      conn = get(conn, Routes.user_path(conn, :show, user.id))
      assert show_view == json_response(conn, 200)
    end

    @tag user_controller: "user_update"
    test "with invalid data returns all errors", %{conn: conn, user: user} do
      conn = patch(conn, Routes.user_path(conn, :update, user.id), changes: @invalid_attrs)
      assert %{} != json_response(conn, 422)["errors"]
    end

    @tag user_controller: "user_update"
    test "when user cant be finded returns an error", %{conn: conn} do
      conn = patch(conn, Routes.user_path(conn, :update, 0), changes: @invalid_attrs)
      assert %{} != json_response(conn, 404)["errors"]
    end

    @tag user_controller: "user_update"
    test "when recived id is invalid returns an error", %{conn: conn} do
      conn = patch(conn, Routes.user_path(conn, :update, "invalid"), changes: @invalid_attrs)
      assert %{} != json_response(conn, 422)["errors"]
    end
  end

  describe "user delete" do
    setup [:login]

    @tag user_controller: "user_delete"
    test "deletes an user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user.id))
      conn = get(conn, Routes.user_path(conn, :show, user.id))

      assert %{} != json_response(conn, 404)["errors"]
    end

    @tag user_controller: "user_delete"
    test "when user cant be finded returns an error", %{conn: conn} do
      conn = delete(conn, Routes.user_path(conn, :delete, 0))
      assert %{} != json_response(conn, 404)["errors"]
    end

    @tag user_controller: "user_delete"
    test "when recived id is invalid returns an error", %{conn: conn} do
      conn = delete(conn, Routes.user_path(conn, :delete, "invalid"))
      assert %{} != json_response(conn, 422)["errors"]
    end
  end

  describe "login" do
    @tag user_controller: "login"
    test "athenticate an user", %{conn: conn} do
      user = user_fixture(@create_attrs)

      credentials = %{
        email: user.email,
        password: @create_attrs.password
      }

      conn = post(conn, Routes.user_path(conn, :login), credentials: credentials)
      assert %{"token" => _token} = json_response(conn, 200)["data"]
    end

    @tag user_controller: "login"
    test "when credentials dont match returns an error", %{conn: conn} do
      credentials = %{
        email: "invalid_email",
        password: "invalid_password"
      }

      conn = post(conn, Routes.user_path(conn, :login), credentials: credentials)
      assert json_response(conn, 422)
    end

    @tag user_controller: "login"
    test "with invalid credentials returns an error", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :login), credentials: %{})
      assert json_response(conn, 422)
    end
  end

  defp create_user(_), do: %{user: user_fixture()}

  defp login(%{conn: conn}) do
    user = user_fixture()
    token = token_fixture(user)

    conn = put_req_header(conn, "authorization", token)

    %{conn: conn, user: user, token: token}
  end
end
