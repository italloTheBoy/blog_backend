defmodule BlogBackend.TimelineFixtures do
  import BlogBackend.AuthFixtures
  import BlogBackend.Timeline

  alias BlogBackend.Repo
  alias BlogBackend.Timeline.{Post, Comment, Reaction}

  @moduledoc """
  This module defines test helpers for creating
  entities via the `BlogBackend.Timeline` context.
  """

  @doc """
  Generate a post.
  """
  @spec post_fixture(map) :: Post.t()
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some text",
        title: "some title",
        user_id: user_fixture().id
      })
      |> create_post()

    post
  end

  @doc """
  Generate a comment.
  """
  @spec comment_fixture(%{
          :father => :comment | :post,
          optional(atom | String.t()) => String.t() | non_neg_integer()
        }) :: Comment.t()
  def comment_fixture(attrs \\ %{father: :post})

  def comment_fixture(%{father: :post} = attrs) do
    user = user_fixture()
    post = post_fixture()

    {:ok, %Comment{} = comment} =
      attrs
      |> Enum.into(%{
        body: "some body",
        user_id: user.id,
        post_id: post.id
      })
      |> BlogBackend.Timeline.create_comment()

    Repo.preload(comment, [:user, :post])
  end

  def comment_fixture(%{father: :comment} = attrs) do
    %Comment{id: comment_id, user_id: user_id} = comment_fixture()

    {:ok, comment} =
      attrs
      |> Enum.into(%{
        type: "like",
        user_id: user_id,
        comment_id: comment_id
      })
      |> BlogBackend.Timeline.create_comment()

    Repo.preload(comment, [:user, :comment])
  end

  @doc """
  Generate a reaction.
  """
  @spec reaction_fixture(%{
          :father => :comment | :post,
          optional(atom | String.t()) => String.t() | non_neg_integer()
        }) :: Reaction.t()
  def reaction_fixture(attrs \\ %{father: :post})

  def reaction_fixture(%{father: :post} = attrs) do
    user = user_fixture()
    post = post_fixture()

    {:ok, %Reaction{} = reaction} =
      attrs
      |> Enum.into(%{
        type: "like",
        user_id: user.id,
        post_id: post.id
      })
      |> BlogBackend.Timeline.create_reaction()

    Repo.preload(reaction, [:user, :post])
  end

  def reaction_fixture(%{father: :comment} = attrs) do
    %Reaction{id: reaction_id, user_id: user_id} = reaction_fixture()

    {:ok, %Reaction{} = reaction} =
      attrs
      |> Enum.into(%{
        type: "like",
        user_id: user_id,
        reaction_id: reaction_id
      })
      |> BlogBackend.Timeline.create_reaction()

    Repo.preload(reaction, [:user, :comment])
  end
end
