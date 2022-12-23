defmodule BlogBackend.Timeline do
  @moduledoc """
  The Timeline context.
  """

  alias BlogBackend.Repo
  alias BlogBackend.Auth.User
  alias BlogBackend.Timeline.{Post, Comment, Reaction}

  import Ecto.Query, warn: false

  @spec authorize(atom, User.t(), nil | Post.t() | Comment.t() | Reaction.t()) ::
          :ok | {:error, :forbidden}
  defdelegate authorize(action, user, params), to: BlogBackend.Timeline.Policy

  #### POST ####

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(attrs)
      {:ok, %Post{}}

      iex> create_post(bad_attrs))
      {:error, %Ecto.Changeset{}}

  """
  @spec create_post(map) :: {:ok, Post.t()} | {:error, Ecto.Changeset.t()}
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single post.

  ## Examples

      iex> get_post(22)
      {:ok, %Post{}}

      iex> get_post(11)
      {:error, :not_found}

      iex> get_post(:invalid)
      {:error, :unprocessable_entity}

  """
  @spec get_post(non_neg_integer()) ::
          {:ok, Post.t()} | {:error, :not_found | :unprocessable_entity}
  def get_post(id) do
    try do
      case Repo.get(Post, id) do
        %Post{} = post -> {:ok, post}
        nil -> {:error, :not_found}
      end
    rescue
      _ -> {:error, :unprocessable_entity}
    end
  end

  @doc """
  Fetches a single post.
  Raises `Ecto.NoResultsError` if the post does not exist.
  Raises `Ecto.Query.CastError` if id type is invalid.


  ## Examples

      iex> get_post!(22)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

      iex> get_post!("invalid")
      ** (Ecto.Query.CastError)

  """
  @spec get_post!(non_neg_integer()) :: Post.t() | nil
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Count a post comments.

  ## Examples

      iex> count_post_comments(%Post{})
      0

  """
  @spec count_post_comments(Post.t() | non_neg_integer()) :: non_neg_integer()
  def count_post_comments(%Post{} = post) do
    %Post{comments: comments} = Repo.preload(post, :comments)

    length(comments)
  end

  @doc """
  Count a post reactions.

  ## Examples

      iex> count_post_reactions(%Post{})
      0

  """
  @spec count_post_reactions(Post.t()) :: non_neg_integer()
  def count_post_reactions(%Post{} = post) do
    %Post{reactions: reactions} = Repo.preload(post, :reactions)

    length(reactions)
  end

  @doc """
  Returns all user posts.

  ## Examples

      iex> list_user_posts(22)
      [%Post{}, ...]

      # iex> list_user_posts(%User{id: 22})
      [%Post{}, ...]

  """
  @spec list_user_posts(non_neg_integer() | User.t()) :: [Post.t()]
  def list_user_posts(%User{id: id}), do: list_user_posts(id)

  def list_user_posts(user_id) do
    from(p in Post,
      where: p.user_id == ^user_id
    )
    |> Repo.all()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_post(Post.t()) :: {:ok, Post.t()}
  def delete_post(post), do: Repo.delete(post)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  @spec change_post(Post.t(), map) :: Ecto.Changeset.t()
  def change_post(%Post{} = post, attrs \\ %{}), do: Post.changeset(post, attrs)

  #### COMMENT ####

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

      iex> create_comment("invalid")
      {:error, :unprocessable_entity}

  """
  @spec create_comment(map) ::
          {:ok, Comment.t()} | {:error, Ecto.Changeset.t() | :unprocessable_entity}
  def create_comment(attrs \\ %{}) do
    try do
      %Comment{}
      |> Comment.changeset(attrs)
      |> Repo.insert()
    rescue
      _ -> {:error, :unprocessable_entity}
    end
  end

  @doc """
  Gets a single comment.

  ## Examples

      iex> get_comment(123)
      {:ok, %Comment}

      iex> get_comment(456)
      {:error, :not_found}

  """
  @spec get_comment(non_neg_integer()) ::
          {:error, :not_found | :unprocessable_entity} | {:ok, %Comment{}}
  def get_comment(id) do
    try do
      case Repo.get(Comment, id) do
        %Comment{} = comment -> {:ok, comment}
        nil -> {:error, :not_found}
      end
    rescue
      _ -> {:error, :unprocessable_entity}
    end
  end

  @doc """
  Gets a single comment.
  Raises `Ecto.NoResultsError` if the Comment does not exist.
  Raises `Ecto.Query.CastError` if id type is invalid.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

      iex> get_comment!("invalid")
      ** (Ecto.Query.CastError)

  """
  @spec get_comment!(non_neg_integer()) :: Comment.t() | nil
  def get_comment!(id), do: Repo.get!(Comment, id)

  @spec count_comment_reactions(Comment.t()) :: non_neg_integer()
  @doc """
  Count a comment reactions.

  ## Examples

      iex> count_comment_reactions(%Commet{})
      0

  """
  def count_comment_reactions(%Comment{} = comment) do
    %Comment{reactions: reactions} = Repo.preload(comment, :reactions)

    length(reactions)
  end

  @spec list_user_comments(User.t()) :: [Comment.t()]
  @doc """
  Returns all user comments.

  ## Examples

      iex> list_user_comments(%User{})
      [%Comment{}, ...]

  """
  def list_user_comments(%User{} = user) do
    user
    |> Repo.preload([:comments])
    |> Map.get(:comments)
  end

  @doc """
  Returns all post comments.

  ## Examples

      iex> list_post_comments( %Post{})
      [%Comment{}, ...]

  """
  @spec list_post_comments(Post.t()) :: [Comment.t()]
  def list_post_comments(%Post{} = post) do
    post
    |> Repo.preload([:comments])
    |> Map.get(:comments)
  end

  @doc """
  Returns all comment comments.

  ## Examples

      iex> list_comment_comments(%Comment{})
      [%Comment{}, ...]

  """
  @spec list_comment_comments(Comment.t()) :: [Comment.t()]
  def list_comment_comments(%Comment{} = comment) do
    comment
    |> Repo.preload([:comments])
    |> Map.get(:comments)
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_comment(Comment.t()) ::
          {:ok, %Comment{}} | {:error, %Ecto.Changeset{}}
  def delete_comment(%Comment{} = comment), do: Repo.delete(comment)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  @spec change_comment(Comment.t(), map) :: Ecto.Changeset.t()
  def change_comment(%Comment{} = comment, attrs \\ %{}), do: Comment.changeset(comment, attrs)

  #### REACTION ####

  @spec create_reaction(map) :: {:ok, Reaction.t()} | {:error, Ecto.Changeset.t()}
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

  @spec get_reaction(non_neg_integer()) :: {:error, :not_found} | {:ok, %Reaction{}}
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

  @spec get_reaction!(non_neg_integer()) :: Reaction.t()
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

  @spec list_user_reactions(User.t()) :: [Reaction.t()]
  @doc """
  Returns all user reactions.

  ## Examples

      iex> list_user_reactions(%User{})
      [%Reaction{}, ...]

  """
  def list_user_reactions(%User{} = user) do
    user
    |> Repo.preload([:reactions])
    |> Map.get(:reactions)
  end

  @spec toggle_reaction_type(Reaction.t()) :: {:ok, Reaction.t()} | {:error, Ecto.Changeset.t()}
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

  def toggle_reaction_type(%Reaction{} = reaction),
    do: {:error, Reaction.changeset(reaction, %{})}

  @spec delete_reaction(Reaction.t()) :: {:ok, Reaction.t()} | {:error, Ecto.Changeset.t()}
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

  @spec change_reaction(Reaction.t(), map) :: Ecto.Changeset.t()
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
