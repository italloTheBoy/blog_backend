defmodule BlogBackend.Timeline do
  @moduledoc """
  The Timeline context.
  """

  alias BlogBackend.Repo
  alias BlogBackend.Auth.User
  alias BlogBackend.Timeline.{Post, Comment, Reaction}

  import Ecto.Query, warn: false

  @spec authorize(
          atom,
          %User{id: non_neg_integer},
          %Post{user_id: non_neg_integer}
          | %Comment{user_id: non_neg_integer}
          | %Reaction{user_id: non_neg_integer}
        ) :: :ok | :error
  defdelegate authorize(action, user, params), to: BlogBackend.Timeline.Policy

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  @spec get_post(Integer.t() | String.t()) :: %Post{} | nil
  @doc """
  Gets a single post.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      nil

  """
  def get_post(id), do: Repo.get(Post, id)

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_post(%Post{}) :: {:ok, %Post{}} | {:error, %Ecto.Changeset{}}
  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post), do: Repo.delete(post)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  alias BlogBackend.Timeline.Comment

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Repo.all(Comment)
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id)

  @spec get_comment(String.t() | pos_integer()) ::
          {:error, :not_found} | {:ok, %Comment{}}
  @doc """
  Gets a single comment.

  ## Examples

      iex> get_comment(123)
      {:ok, %Comment}

      iex> get_comment(456)
      {:error, :not_found}

  """
  def get_comment(id) do
    case Repo.get(Comment, id) do
      %Comment{} = comment -> {:ok, comment}
      nil -> {:error, :not_found}
    end
  end

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_comment(%Comment{}) ::
          {:ok, %Comment{}} | {:error, %Ecto.Changeset{}}
  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end

  alias BlogBackend.Timeline.Reaction

  @doc """
  Returns the list of reactions.

  ## Examples

      iex> list_reactions()
      [%Reaction{}, ...]

  """
  def list_reactions do
    Repo.all(Reaction)
  end

  @doc """
  Gets a single reaction.

  Raises `Ecto.NoResultsError` if the Reaction does not exist.

  ## Examples

      iex> get_reaction!(123)
      %Reaction{}

      iex> get_reaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reaction!(id), do: Repo.get!(Reaction, id)

  @spec get_reaction(String.t() | pos_integer()) ::
          {:error, :not_found} | {:ok, %Reaction{}}
  @doc """
  Gets a single reaction.

  ## Examples

      iex> get_reaction(123)
      {:ok, %Reaction{}}

      iex> get_reaction(456)
      {:error, :not_found}

  """
  def get_reaction(id) do
    case Repo.get(Reaction, id) do
      %Reaction{} = reaction -> {:ok, reaction}
      nil -> {:error, :not_found}
    end
  end

  @doc """
  Creates a reaction.

  ## Examples

      iex> create_reaction(%{field: value})
      {:ok, %Reaction{}}

      iex> create_reaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reaction(attrs \\ %{}) do
    %Reaction{}
    |> Reaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a reaction.

  ## Examples

      iex> update_reaction(reaction, %{field: new_value})
      {:ok, %Reaction{}}

      iex> update_reaction(reaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reaction(%Reaction{} = reaction, attrs) do
    reaction
    |> Reaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Toggle reaction type.

  ## Examples

      iex> update_reaction(%Reaction{type: "like"})
      {:ok, %Reaction{type: "dislike"}}

      iex> update_reaction(%Reaction{type: "dislike"})
      {:ok, %Reaction{type: "like"}}

      iex> update_reaction(%Reaction{type: "invalid_reaction"})
      {:error, %Ecto.Changeset{}}

  """

  @spec toggle_reaction_type(%Reaction{type: String.t()}) ::
          {:ok, %Reaction{}} | {:error, %Ecto.Changeset{}}

  def toggle_reaction_type(%Reaction{type: "like"} = reaction) do
    reaction
    |> Reaction.changeset(%{type: "dislike"})
    |> Repo.update()
  end

  def toggle_reaction_type(%Reaction{type: "dislike"} = reaction) do
    reaction
    |> Reaction.changeset(%{type: "like"})
    |> Repo.update()
  end

  def toggle_reaction_type(reaction), do: {:error, Reaction.changeset(reaction, %{})}

  @doc """
  Deletes a reaction.

  ## Examples

      iex> delete_reaction(reaction)
      {:ok, %Reaction{}}

      iex> delete_reaction(reaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reaction(%Reaction{} = reaction) do
    Repo.delete(reaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reaction changes.

  ## Examples

      iex> change_reaction(reaction)
      %Ecto.Changeset{data: %Reaction{}}

  """
  def change_reaction(%Reaction{} = reaction, attrs \\ %{}) do
    Reaction.changeset(reaction, attrs)
  end
end
