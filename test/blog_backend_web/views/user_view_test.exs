defmodule BlogBackendWeb.UserViewTest do
  use BlogBackendWeb.ConnCase, async: true

  import BlogBackend.AuthFixtures

  alias Phoenix.View
  alias BlogBackendWeb.UserView

  @moduletag :user_view

  @user_fields [
    :id,
    :email,
    :username
  ]

  setup do: {:ok, user: user_fixture()}

  @tag user_view: "token"
  test "renders token.json", %{user: user} do
    "Bearer " <> token = token_fixture(user)

    assert View.render(UserView, "token.json", token: token) == %{
             data: %{token: token}
           }
  end

  @tag user_view: "index"
  test("renders index.json", %{user: user},
    do:
      assert(
        %{
          data: %{
            users: [take_user(user)]
          }
        } == View.render(UserView, "index.json", users: [user])
      )
  )

  @tag user_view: "id"
  test("renders id.json", %{user: user},
    do:
      assert(
        View.render(UserView, "id.json", user: user) == %{
          data: take_user(user, [:id])
        }
      )
  )

  @tag user_view: "show"
  test("renders show.json", %{user: user},
    do:
      assert(
        %{
          data: %{
            user: take_user(user)
          }
        } == View.render(UserView, "show.json", user: user)
      )
  )

  describe "renders user.json" do
    @tag user_view: "user"
    test("with no option render all fields", %{user: user},
      do:
        assert(
          take_user(user) ==
            View.render(UserView, "user.json", user: user)
        )
    )

    @tag user_view: "user"
    test "with :only option renders only slected fields", %{user: user} do
      selected_fields = select_random_fields(@user_fields)

      assert take_user(user, selected_fields) ==
               View.render(UserView, "user.json",
                 user: user,
                 only: selected_fields
               )
    end
  end

  defp take_user(user, selected_fields \\ @user_fields)
       when is_list(selected_fields),
       do: Map.take(user, selected_fields)
end
