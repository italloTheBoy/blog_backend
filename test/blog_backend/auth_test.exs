defmodule BlogBackend.AuthTest do
  use BlogBackend.DataCase, async: true

  import BlogBackend.AuthFixtures
  import BlogBackend.Auth

  alias BlogBackend.Auth
  alias BlogBackend.Auth.User

  @moduletag :auth

  describe "user" do
    @valid_attrs %{
      email: "some_email@email.com",
      username: "some_username",
      password: "some password",
      password_confirmation: "some password"
    }

    @update_attrs %{
      email: "some_updated_email@email.com",
      username: "updated_username",
      password: "updated password"
    }

    @invalid_attrs %{email: nil, password: nil, username: nil}

    @tag auth: "create_user"
    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = create_user(@valid_attrs)

      assert @valid_attrs.email == user.email
      assert @valid_attrs.username == user.username

      assert true ==
               Argon2.verify_pass(@valid_attrs.password, user.password)
    end

    @tag auth: "create_user"
    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@invalid_attrs)
    end

    @tag auth: "get_user"
    test "get_user/1 fetches a single user" do
      user = user_fixture()

      assert {:ok, %User{user | password: nil}} == get_user(user.id)
    end

    @tag auth: "get_user"
    test "get_user/1 return an error when user cant be finded" do
      assert {:error, :not_found} == get_user(0)
    end

    @tag auth: "get_user!"
    test "get_user!/1 fetches a single user" do
      user = %User{user_fixture() | password: nil}

      assert user == get_user!(user.id)
    end

    @tag auth: "get_user!"
    test "get_user!/1 raises when user cant be finded" do
      assert_raise Ecto.NoResultsError, fn -> get_user!(0) end
    end

    @tag auth: "search_user"
    test "search_user/1 returns a list of users by given data" do
      user = %User{user_fixture() | password: nil}

      assert [user] == search_user(user.username)
      assert [user] == search_user(user.email)
    end

    @tag auth: "update_user"
    test "update_user/2 with valid data updates the user" do
      user = user_fixture()

      assert {:ok, %User{} = updated_user} = update_user(user, @update_attrs)

      assert @update_attrs.email == updated_user.email
      assert @update_attrs.username == updated_user.username

      assert true ==
               Argon2.verify_pass(@update_attrs.password, updated_user.password)

      assert %User{updated_user | password: nil} == get_user!(user.id)
    end

    @tag auth: "update_user"
    test "update_user/2 with invalid data returns error changeset" do
      user = %User{user_fixture() | password: nil}

      assert {:error, %Ecto.Changeset{}} = update_user(user, @invalid_attrs)
      assert user == get_user!(user.id)
    end

    @tag auth: "delete_user"
    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Auth.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_user!(user.id) end
    end

    @tag auth: "change_user"
    test "change_user/1 returns a user changeset" do
      user = user_fixture()

      assert %Ecto.Changeset{} = change_user(user)
    end

    @tag auth: "check_credentials"
    test "check_credentials/2 pass if recived credentials are valid" do
      user = user_fixture(@valid_attrs)

      assert :ok == check_credentials(user.email, @valid_attrs.password)
    end

    @tag auth: "check_credentials"
    test "check_credentials/2 returns an with invalid email" do
      user = user_fixture(@valid_attrs)

      assert {:error, :unprocessable_entity} ==
               check_credentials("invalid", @valid_attrs.password)
    end

    @tag auth: "check_credentials"
    test "check_credentials/2 returns an with invalid password" do
      user = user_fixture(@valid_attrs)

      assert {:error, :unprocessable_entity} ==
               check_credentials(user.email, "invalid")
    end
  end
end
