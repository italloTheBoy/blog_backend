defmodule BlogBackend.TimelineTest do
  use BlogBackend.DataCase

  alias BlogBackend.Timeline

  describe "posts" do
    alias BlogBackend.Timeline.Post

    import BlogBackend.TimelineFixtures

    @invalid_attrs %{text: nil, title: nil}

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Timeline.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Timeline.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{text: "some text", title: "some title"}

      assert {:ok, %Post{} = post} = Timeline.create_post(valid_attrs)
      assert post.text == "some text"
      assert post.title == "some title"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{text: "some updated text", title: "some updated title"}

      assert {:ok, %Post{} = post} = Timeline.update_post(post, update_attrs)
      assert post.text == "some updated text"
      assert post.title == "some updated title"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_post(post, @invalid_attrs)
      assert post == Timeline.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Timeline.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Timeline.change_post(post)
    end
  end

  describe "comments" do
    alias BlogBackend.Timeline.Comment

    import BlogBackend.TimelineFixtures

    @invalid_attrs %{comment: nil}

    test "list_comments/0 returns all comments" do
      comment = comment_fixture()
      assert Timeline.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      assert Timeline.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment" do
      valid_attrs = %{comment: "some comment"}

      assert {:ok, %Comment{} = comment} = Timeline.create_comment(valid_attrs)
      assert comment.comment == "some comment"
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_comment(@invalid_attrs)
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
    alias BlogBackend.Timeline.Reaction

    import BlogBackend.TimelineFixtures

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
