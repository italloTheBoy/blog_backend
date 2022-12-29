defmodule BlogBackend.TimelineTest do
  use BlogBackend.DataCase, async: true

  import BlogBackend.{Auth, Timeline}
  import BlogBackend.AuthFixtures
  import BlogBackend.TimelineFixtures

  alias Ecto.NoResultsError
  alias Ecto.CastError
  alias BlogBackend.Auth
  alias BlogBackend.Auth.User
  alias BlogBackend.Timeline
  alias BlogBackend.Timeline.{Post, Comment, Reaction}

  @moduletag :timeline

  describe "post" do
    @invalid_attrs %{user_id: nil, body: nil, title: nil}

    @tag posts: "create_post"
    test "create_post/1 with valid data creates a post" do
      user = user_fixture()

      valid_attrs = %{
        user_id: user.id,
        title: "some title",
        body: "some body"
      }

      assert {:ok, %Post{} = post} = Timeline.create_post(valid_attrs)
      assert post.user_id == user.id
      assert post.title == "some title"
      assert post.body == "some body"
    end

    @tag posts: "create_post"
    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_post(@invalid_attrs)
    end

    @tag posts: "get_post"
    test "get_post/1 with valid id returns a post" do
      post = post_fixture()

      assert {:ok, post} == Timeline.get_post(post.id)
    end

    @tag posts: "get_post"
    test "get_post/1 with invalid id returns an error" do
      assert {:error, :not_found} == Timeline.get_post(11)
    end

    @tag posts: "get_post"
    test "get_post/1 with invalid id type returns an error" do
      assert {:error, :unprocessable_entity} == Timeline.get_post(:invalid)
    end

    @tag posts: "get_post!"
    test "get_post!/1 with valid id returns an post" do
      post = post_fixture()

      assert post == Timeline.get_post!(post.id)
    end

    @tag posts: "get_post!"
    test "get_post!/1 with invalid id returns an error" do
      assert %Ecto.NoResultsError{} =
               get_post!(11)
               |> catch_error()
    end

    @tag posts: "get_post!"
    test "get_post!/1 with invalid id type raise the app" do
      assert_raise ArgumentError, fn -> get_post!(nil) end
    end

    @tag posts: "delete_post"
    test "delete_post/1 with valid data deletes the post" do
      post = post_fixture()

      assert {:ok, %Post{}} = Timeline.delete_post(post)
      assert {:error, :not_found} == Timeline.get_post(post.id)
    end

    @tag posts: "delete_post"
    test "delete_post/1 with invalid data raise the app" do
      assert_raise FunctionClauseError, fn -> delete_post("invalid") end
    end

    @tag posts: "change_post"
    test "change_post/1 returns a post changeset" do
      post = post_fixture()

      assert %Ecto.Changeset{} = Timeline.change_post(post)
    end
  end

  describe "comment" do
    @invalid_attrs %{user_id: nil, post_id: nil, comment_id: nil, body: nil}

    @tag comments: "create_comment"
    test "create_comment/1 with valid data whem father is :post, comment a post" do
      %Post{user_id: user_id, id: post_id} = post_fixture()

      valid_attrs = %{
        body: "some comment",
        father: :post,
        user_id: user_id,
        post_id: post_id
      }

      assert {:ok, %Comment{} = comment} = Timeline.create_comment(valid_attrs)
      assert comment.body == valid_attrs.body
      assert comment.user_id == user_id
      assert comment.post_id == post_id
    end

    @tag comments: "create_comment"
    test "create_comment/1 with valid data whem father is :comment, comment other comment" do
      %Comment{user_id: user_id, id: comment_id} = comment_fixture()

      valid_attrs = %{
        body: "some comment",
        father: :comment,
        user_id: user_id,
        comment_id: comment_id
      }

      assert {:ok, %Comment{} = comment} = Timeline.create_comment(valid_attrs)
      assert comment.body == valid_attrs.body
      assert comment.user_id == user_id
      assert comment.comment_id == comment_id
    end

    @tag comments: "create_comment"
    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_comment(@invalid_attrs)
    end

    @tag comments: "create_comment"
    test "create_comment/1 with invalid data type returns error" do
      assert {:error, :unprocessable_entity} = Timeline.create_comment("invalid")
    end

    @tag comments: "get_comment"
    test "get_comment/1 with valid id returns an comment" do
      comment = comment_fixture()

      assert {:ok, comment} == get_comment(comment.id)
    end

    @tag comments: "get_comment"
    test "get_comment/1 with id who doesnt have a comment returns an error" do
      assert {:error, :not_found} == get_comment(11)
    end

    @tag comments: "get_comment"
    test "get_comment/1 with invalid id type returns an error" do
      assert {:error, :unprocessable_entity} == get_comment("invalid")
    end

    @tag comments: "get_comment!"
    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()

      assert comment == get_comment!(comment.id)
    end

    @tag comments: "get_comment!"
    test "get_comment!/1 with id case any comment de found returns an error" do
      assert %Ecto.NoResultsError{} =
               get_comment!(11)
               |> catch_error()
    end

    @tag comments: "get_comment!"
    test "get_comment!/1 with invalid id type raise the app" do
      assert_raise ArgumentError, fn -> get_comment!(nil) end
    end

    @tag comments: "list_comment_comments"
    test "list_comment_comments/1 with %Comment{} returns all post comments" do
      %Comment{comment_id: father_comment_id} = comment = comment_fixture(%{father: :comment})

      father_comment = get_comment!(father_comment_id)

      assert [comment] == list_comment_comments(father_comment)
    end

    @tag comments: "list_comment_comments"
    test "list_comment_comments/1 with invalid data raise the app" do
      assert :function_clause == list_comment_comments("invalid") |> catch_error()
    end

    @tag comments: "delete_comment"
    test "delete_comment/1 with valid data deletes the comment" do
      comment = comment_fixture()

      assert {:ok, %Comment{}} = delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> get_comment!(comment.id) end
    end

    @tag comments: "delete_comment"
    test "delete_comment/1 with invalid data raise the app" do
      assert_raise FunctionClauseError, fn -> delete_comment("invalid") end
    end

    @tag comments: "change_comment"
    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()

      assert %Ecto.Changeset{} = Timeline.change_comment(comment)
    end
  end

  describe "reaction" do
    @invalid_attrs %{user_id: nil, post_id: nil, comment_id: nil, type: nil}

    @tag reactions: "create_reaction"
    test "create_reaction/1 with valid data when father is a post, react a post" do
      %Post{id: post_id, user_id: user_id} = post_fixture()

      valid_attrs = %{
        type: "like",
        user_id: user_id,
        post_id: post_id
      }

      assert {:ok, %Reaction{} = reaction} = Timeline.create_reaction(valid_attrs)
      assert reaction.type == "like"
      assert reaction.user_id == user_id
      assert reaction.post_id == post_id
    end

    @tag reactions: "create_reaction"
    test "create_reaction/1 with valid data when father is a comment, react a comment" do
      %Comment{id: comment_id, user_id: user_id} = comment_fixture()

      valid_attrs = %{
        type: "like",
        user_id: user_id,
        comment_id: comment_id
      }

      assert {:ok, %Reaction{} = reaction} = Timeline.create_reaction(valid_attrs)
      assert reaction.type == "like"
      assert reaction.user_id == user_id
      assert reaction.comment_id == comment_id
    end

    @tag reactions: "create_reaction"
    test "create_reaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_reaction(@invalid_attrs)
    end

    @tag reactions: "create_reaction"
    test "create_reaction/1 with invalid data typ raise the app" do
      assert_raise CastError, fn -> create_reaction("invalid") end
    end

    @tag reactions: "get_reaction"
    test "get_reaction/1 with existing id fethes an reaction" do
      %Reaction{} = reaction = reaction_fixture()

      assert {:ok, reaction} == get_reaction(reaction.id)
    end

    @tag reactions: "get_reaction"
    test "get_reaction/1 with nonexistent id returns an not found error" do
      %Reaction{} = reaction = reaction_fixture()

      delete_reaction(reaction)

      assert {:error, :not_found} == get_reaction(reaction.id)
    end

    @tag reactions: "get_reaction"
    test "get_reaction/1 with invalid id returns an error" do
      assert {:error, :unprocessable_entity} == get_reaction(nil)
    end

    @tag reactions: "get_reaction!"
    test "get_reaction!/1 with existing id fethes an reaction" do
      %Reaction{} = reaction = reaction_fixture()

      assert reaction == get_reaction!(reaction.id)
    end

    @tag reactions: "get_reaction!"
    test "get_reaction!/1 with nonexistent id raise the app" do
      assert_raise NoResultsError, fn -> get_reaction!(0) end
    end

    @tag reactions: "get_reaction!"
    test "get_reaction!/1 with invalid id raise the app" do
      assert_raise ArgumentError, fn -> get_reaction!(nil) end
    end

    @tag reactions: "get_reaction_by_fathers"
    test "get_reaction_by_fathers/1 with user and post ids return a reaction" do
      %Reaction{user_id: user_id, post_id: post_id} = reaction_fixture()

      assert {:ok, %Reaction{}} = get_reaction_by_fathers(%{user_id: user_id, post_id: post_id})
    end

    @tag reactions: "get_reaction_by_fathers"
    test "get_reaction_by_fathers/1 with user and comment ids return a reaction" do
      %Reaction{
        user_id: user_id,
        comment_id: comment_id
      } = reaction_fixture(%{father: :comment})

      assert {:ok, %Reaction{}} =
               get_reaction_by_fathers(%{user_id: user_id, comment_id: comment_id})
    end

    @tag reactions: "get_reaction_by_fathers"
    test "get_reaction_by_fathers/1 with user, post and comment return an error" do
      %Reaction{user_id: user_id, post_id: post_id, comment_id: comment_id} = reaction_fixture()

      assert {:error, :unprocessable_entity} ==
               get_reaction_by_fathers(%{
                 user_id: user_id,
                 post_id: post_id,
                 comment_id: comment_id
               })
    end

    @tag reactions: "get_reaction_by_fathers"
    test "get_reaction_by_fathers/1 when reaction cant be finded return an error" do
      assert {:error, :not_found} == get_reaction_by_fathers(%{user_id: 0, post_id: 0})
    end

    @tag reactions: "get_reaction_by_fathers"
    test "get_reaction_by_fathers/1 with invalid data return an error" do
      assert_raise FunctionClauseError, fn -> get_reaction_by_fathers(%{}) end
    end

    @tag reactions: "toggle_reaction_type"
    test "toggle_reaction_type/1 with valid %Reaction{} toggle reaction type" do
      reaction = reaction_fixture(%{type: "like", father: :post})

      assert {:ok, %Reaction{type: "dislike"}} = toggle_reaction_type(reaction)
      assert %Reaction{type: "dislike"} = get_reaction!(reaction.id)
    end

    @tag reactions: "toggle_reaction_type"
    test "toggle_reaction_type/1 with %Reaction{} when type is invalid toggle reaction type" do
      reaction = reaction_fixture(%{type: "like", father: :post})

      invalid_reaction = %{reaction | type: "invalid_like"}

      assert {:error, %Ecto.Changeset{}} = toggle_reaction_type(invalid_reaction)
    end

    @tag reactions: "toggle_reaction_type"
    test "toggle_reaction_type/1 with invalid data raise the app" do
      assert_raise FunctionClauseError, fn -> toggle_reaction_type(nil) end
    end

    @tag reactions: "delete_reaction"
    test "delete_reaction/1 with %Reaction{} deletes the reaction" do
      reaction = reaction_fixture()

      assert {:ok, %Reaction{}} = Timeline.delete_reaction(reaction)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_reaction!(reaction.id) end
    end

    @tag reactions: "delete_reaction"
    test "delete_reaction/1 with invalid data raise the app" do
      assert_raise ArgumentError, fn -> Timeline.get_reaction!(nil) end
    end

    @tag reactions: "change_reaction"
    test "change_reaction/2 returns a reaction changeset" do
      reaction = reaction_fixture()
      assert %Ecto.Changeset{} = Timeline.change_reaction(reaction)
    end
  end

  describe "users_posts" do
    @tag users_posts: "list_user_posts"
    test "list_user_posts/1 with numeric id returns all user posts" do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})

      assert [%Post{} = post] == Timeline.list_user_posts(user.id)
    end

    @tag users_posts: "list_user_posts"
    test "list_user_posts/1 with %User{} returns all user posts" do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})

      assert [%Post{} = post] == Timeline.list_user_posts(user)
    end
  end

  describe "users_comments" do
    @tag users_comments: "list_user_comments"
    test "list_user_comments/1 with %User{} returns all user comments" do
      comment = comment_fixture()

      %User{} = user = Auth.get_user!(comment.user_id)

      assert [comment] == list_user_comments(user)
    end

    @tag users_comments: "list_user_comments"
    test "list_user_comments/1 with invalid data raise the app" do
      assert_raise FunctionClauseError, fn -> list_user_comments(nil) end
    end
  end

  describe "users_reactions" do
    @tag users_reactions: "list_user_reactions"
    test "list_user_reactions/1 with valid user returns all user reactions" do
      reaction = reaction_fixture()

      %User{} = user = get_user!(reaction.user_id)

      assert [reaction] == list_user_reactions(user)
    end

    @tag users_reactions: "list_user_reactions"
    test "list_user_reactions/1 invalid user raise the app" do
      assert_raise FunctionClauseError, fn -> list_user_reactions(nil) end
    end
  end

  describe "posts_comments" do
    @tag posts_comments: "count_post_comments"
    test "count_post_comments/1 with %Post{} returns the number of comments" do
      post = post_fixture()

      assert 0 == Timeline.count_post_comments(post)
    end

    @tag posts_comments: "count_post_comments"
    test "count_post_comments/1 with invalid param raise the app" do
      assert :function_clause =
               Timeline.count_post_comments(:invalid)
               |> catch_error()
    end

    @tag posts_comments: "list_post_comments"
    test "list_post_comments/1 with %Post{} returns all post comments" do
      %Comment{post_id: post_id} = comment = comment_fixture(%{father: :post})

      post = get_post!(post_id)

      assert [comment] == list_post_comments(post)
    end

    @tag posts_comments: "list_post_comments"
    test "list_post_comments/1 with invalid data raise the app" do
      assert :function_clause == list_post_comments("invalid") |> catch_error()
    end
  end

  describe "posts_reactions" do
    @tag posts_reactions: "count_post_reactions"
    test "count_post_reactions/1 with %Post{} returns the number of reactions" do
      post = post_fixture()

      assert 0 == Timeline.count_post_reactions(post)
    end

    @tag posts_reactions: "count_post_reactions"
    test "count_post_reactions/1 with invalid param raise the app" do
      assert :function_clause =
               Timeline.count_post_reactions(:invalid)
               |> catch_error()
    end
  end

  describe "comments_reactions" do
    @tag comments_reactions: "count_comment_reactions"
    test "count_comment_reactions/1 with valid %Comment{} count her reactions" do
      %Reaction{comment_id: comment_id} = reaction_fixture(%{father: :comment})

      %Comment{} = comment = get_comment!(comment_id)

      assert 1 == count_comment_reactions(comment)
    end

    @tag comments_reactions: "count_comment_reactions"
    test "count_comment_reactions/1 with invalid data raise the app" do
      assert_raise FunctionClauseError, fn -> count_comment_reactions(nil) end
    end
  end
end
