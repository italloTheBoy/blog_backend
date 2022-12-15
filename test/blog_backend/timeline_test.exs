defmodule BlogBackend.TimelineTest do
  use BlogBackend.DataCase, async: true

  import BlogBackend.Timeline
  import BlogBackend.AuthFixtures
  import BlogBackend.TimelineFixtures

  alias Ecto.Query.CastError
  alias BlogBackend.Repo
  alias BlogBackend.Timeline
  alias BlogBackend.Timeline.{Post, Comment, Reaction}

  @moduletag :timeline

  describe "posts" do
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
      assert nil == Timeline.get_post!(11)
    end

    @tag posts: "get_post!"
    test "get_post!/1 with invalid id type raise the app" do
      assert %CastError{} = Timeline.get_post!(:invalid) |> catch_error()
    end

    @tag posts: "count_post_comments"
    test "count_post_comments/1 with %Post{} returns the number of comments" do
      post = post_fixture()

      assert 0 == Timeline.count_post_comments(post)
    end

    @tag posts: "count_post_comments"
    test "count_post_comments/1 with invalid param raise the app" do
      assert :function_clause =
               Timeline.count_post_comments(:invalid)
               |> catch_error()
    end

    @tag posts: "count_post_reactions"
    test "count_post_reactions/1 with %Post{} returns the number of reactions" do
      post = post_fixture()

      assert 0 == Timeline.count_post_reactions(post)
    end

    @tag posts: "count_post_reactions"
    test "count_post_reactions/1 with invalid param raise the app" do
      assert :function_clause =
               Timeline.count_post_reactions(:invalid)
               |> catch_error()
    end

    @tag posts: "list_user_posts"
    test "list_user_posts/1 with numeric id returns all user posts" do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})

      assert [%Post{} = post] == Timeline.list_user_posts(user.id)
    end

    @tag posts: "list_user_posts"
    test "list_user_posts/1 with %User{} returns all user posts" do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})

      assert [%Post{} = post] == Timeline.list_user_posts(user)
    end

    @tag posts: "delete_post"
    test "delete_post/1 with valid %Post{} deletes the post" do
      post = post_fixture()

      assert {:ok, %Post{}} = Timeline.delete_post(post)
      assert {:error, :not_found} == Timeline.get_post(post.id)
    end

    @tag posts: "delete_post"
    test "delete_post/1 with invalid post return an error" do
      assert {:error, :not_found} = Timeline.delete_post(nil)
    end

    @tag posts: "change_post"
    test "change_post/1 returns a post changeset" do
      post = post_fixture()

      assert %Ecto.Changeset{} = Timeline.change_post(post)
    end
  end

  describe "comments" do
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

    test "list_comments/0 returns all comments" do
      comment = comment_fixture()
      assert Timeline.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      assert Timeline.get_comment!(comment.id) == comment
    end

    test "update_comment/2 with valid data updates the comment" do
      comment = comment_fixture()
      update_attrs = %{comment: "some updated comment"}

      assert {:ok, %Comment{} = comment} = Timeline.update_comment(comment, update_attrs)
      assert comment.comment == "some updated comment"
    end

    test "update_comment/2 with invalid data returns error changeset" do
      comment = comment_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_comment(comment, @invalid_attrs)
      assert comment == Timeline.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = Timeline.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = Timeline.change_comment(comment)
    end
  end

  describe "reactions" do
    @invalid_attrs %{type: nil}

    test "list_reactions/0 returns all reactions" do
      reaction = reaction_fixture()
      assert Timeline.list_reactions() == [reaction]
    end

    test "get_reaction!/1 returns the reaction with given id" do
      reaction = reaction_fixture()
      assert Timeline.get_reaction!(reaction.id) == reaction
    end

    test "create_reaction/1 with valid data creates a reaction" do
      valid_attrs = %{type: "some type"}

      assert {:ok, %Reaction{} = reaction} = Timeline.create_reaction(valid_attrs)
      assert reaction.type == "some type"
    end

    test "create_reaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_reaction(@invalid_attrs)
    end

    test "update_reaction/2 with valid data updates the reaction" do
      reaction = reaction_fixture()
      update_attrs = %{type: "some updated type"}

      assert {:ok, %Reaction{} = reaction} = Timeline.update_reaction(reaction, update_attrs)
      assert reaction.type == "some updated type"
    end

    test "update_reaction/2 with invalid data returns error changeset" do
      reaction = reaction_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_reaction(reaction, @invalid_attrs)
      assert reaction == Timeline.get_reaction!(reaction.id)
    end

    test "delete_reaction/1 deletes the reaction" do
      reaction = reaction_fixture()
      assert {:ok, %Reaction{}} = Timeline.delete_reaction(reaction)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_reaction!(reaction.id) end
    end

    test "change_reaction/1 returns a reaction changeset" do
      reaction = reaction_fixture()
      assert %Ecto.Changeset{} = Timeline.change_reaction(reaction)
    end
  end
end
