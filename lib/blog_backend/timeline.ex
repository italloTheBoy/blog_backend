defmodule BlogBackend.Timeline do
  @moduledoc """
  The Timeline context.
  """

  alias BlogBackend.Repo
  alias BlogBackend.Auth.User
  alias BlogBackend.Timeline.{Post, Comment, Reaction}

  import Ecto.Query, warn: false

  @type commentable_entity :: Post.t() | Comment.t()
  @type reactable_entity :: Post.t() | Comment.t()
  @type metricable_entity :: Post.t() | Comment.t()

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

      iex> w(11)
      {:error, :not_found}

      iex> get_post(:invalid)
      {:error, :unprocessable_entity}

  """
  @spec get_post(non_neg_integer()) ::
          {:ok, Post.t()} | {:error, :not_found | :unprocessable_entity}
  def get_post(id) do
    case Repo.get(Post, id) do
      %Post{} = post -> {:ok, post}
      nil -> {:error, :not_found}
    end
  rescue
    _ -> {:error, :unprocessable_entity}
  end

  @doc """
  Fetches a single post.

  Raises `Ecto.NoResultsError` if the post does not exist.

  ## Examples

      iex> get_post!(22)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_post!(non_neg_integer()) :: Post.t()
  def get_post!(id), do: Repo.get!(Post, id)

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
      where: p.user_id == ^user_id,
      order_by: [desc: p.inserted_at]
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
  Returns all %Post{} or %Comment{} comments.

  ## Examples

      iex> list_comments(%Post{})
      [%Comment{}, ...]

      iex> list_comments (%Comment{})
      [%Comment{}, ...]

  """
  @spec list_comments(commentable_entity) :: [Comment.t()]
  def list_comments(commentable)
      when is_struct(commentable, Post) or is_struct(commentable, Comment) do
    commentable
    |> Repo.preload([:comments])
    |> Map.get(:comments)
  end

  @spec list_reactions(reactable_entity) :: [Reaction.t()]
  @doc """
  Returns an %Post{} or %Comment{} reactions

  ## Examples

      iex> list_reactions(%Post{})
      [%Reaction{}, ...]

      iex> list_reactions(%Comment{})
      [%Reaction{}, ...]

  """
  def list_reactions(reactable)
      when is_struct(reactable, Post) or is_struct(reactable, Comment),
      do:
        reactable
        |> Repo.preload(:reactions)
        |> Map.get(:reactions)

  @spec list_reactions(reactable_entity, type: String.t()) :: [Reaction.t()]
  @doc """
  Returns an %Post{} or %Comment{} likes

  ## Examples

      iex> list_reactions(%Post{}, type: "like")
      [%Reaction{type: "like"}, ...]

      iex> list_reactions(%Comment{}, type: "dislike")
      [%Reaction{type: "dislike"}, ...]

  """
  def list_reactions(reactable, type: type)
      when is_struct(reactable, Post) or is_struct(reactable, Comment)
      when type in ["like", "dislike"],
      do:
        reactable
        |> Repo.preload(reactions: from(r in Reaction, where: r.type == ^type))
        |> Map.get(:reactions)

  @spec get_metrics(metricable_entity) :: %{
          reactions: integer,
          likes: integer,
          dislikes: integer,
          comments: integer
        }
  @doc """
  Returns an %Post{} or %Comment{} metrics

  ## Examples

      iex> get_metrics(%Post{})
      %{
        reactions: 0,
        likes: 0,
        dislikes: 0,
        comments: 0
      }

      iex> get_metrics(%Comment{})
      %{
        reactions: 0,
        likes: 0,
        dislikes: 0,
        comments: 0
      }

  """
  def get_metrics(metricable)
      when is_struct(metricable, Post) or is_struct(metricable, Comment) do
    reactions_count = list_reactions(metricable) |> length()
    likes_count = list_reactions(metricable, type: "like") |> length()
    dislikes_count = list_reactions(metricable, type: "dislike") |> length()
    comments_count = list_comments(metricable) |> length()

    %{
      reactions: reactions_count,
      likes: likes_count,
      dislikes: dislikes_count,
      comments: comments_count
    }
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

  @spec get_reaction(non_neg_integer()) ::
          {:error, :not_found | :unprocessable_entity} | {:ok, %Reaction{}}
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
  rescue
    _ -> {:error, :unprocessable_entity}
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

  @spec get_reaction_by_fathers(%{
          :user_id => integer(),
          (:comment_id | :post_id) => integer()
        }) :: {:error, :not_found} | {:ok, Reaction.t()}
  @doc """
  Gets a single reaction by fathers ids.

  ## Examples
      valid param maps:
        -- %{user_id: user_id, post_id: post_id}
        -- %{user_id: user_id, comment_id: comment_id}

      iex> get_reaction_by_fathers(valid_map)
      {:ok, %Reaction{}}

      iex> get_reaction(valid_map_contain_inexistent_ids)
      {:error, :not_found}
  """
  def get_reaction_by_fathers(%{user_id: _, post_id: _, comment_id: _}),
    do: {:error, :unprocessable_entity}

  def get_reaction_by_fathers(%{user_id: user_id, post_id: post_id}) do
    from(r in Reaction,
      where: [user_id: ^user_id, post_id: ^post_id]
    )
    |> Repo.one()
    |> case do
      %Reaction{} = reaction -> {:ok, reaction}
      nil -> {:error, :not_found}
    end
  rescue
    _ -> {:error, :unprocessable_entity}
  end

  def get_reaction_by_fathers(%{user_id: user_id, comment_id: comment_id}) do
    from(r in Reaction,
      where: [user_id: ^user_id, comment_id: ^comment_id]
    )
    |> Repo.one()
    |> case do
      %Reaction{} = reaction -> {:ok, reaction}
      nil -> {:error, :not_found}
    end
  rescue
    _ -> {:error, :unprocessable_entity}
  end

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
