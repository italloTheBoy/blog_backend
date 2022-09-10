defmodule BlogBackend.AuthTest do
  use BlogBackend.DataCase

  alias BlogBackend.Auth

  describe "user" do
    alias BlogBackend.Auth.User

    import BlogBackend.AuthFixtures

    @invalid_attrs %{email: nil, password: nil, username: nil}

    test "list_user/0 returns all user" do
      user = user_fixture()
      assert Auth.list_user() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Auth.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{email: "some email", password: "some password", username: "some username"}

      assert {:ok, %User{} = user} = Auth.create_user(valid_attrs)
      assert user.email == "some email"
      assert user.password == "some password"
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{email: "some updated email", password: "some updated password", username: "some updated username"}

      assert {:ok, %User{} = user} = Auth.update_user(user, update_attrs)
      assert user.email == "some updated email"
      assert user.password == "some updated password"
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_user(user, @invalid_attrs)
      assert user == Auth.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Auth.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Auth.change_user(user)
    end
  end
end
