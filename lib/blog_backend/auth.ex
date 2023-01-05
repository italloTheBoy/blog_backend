defmodule BlogBackend.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false

  alias Phoenix.LiveView.Plug
  alias BlogBackend.Repo
  alias BlogBackend.Auth.User

  @spec authorize(atom, User.t(), User.t()) ::
          :ok | {:error, :forbidden}
  defdelegate authorize(action, user, params),
    to: BlogBackend.Auth.Policy

  @spec create_user(map) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @spec get_user(integer() | String.t()) ::
          {:ok, User.t()} | {:error, :not_found}
  @doc """
  Gets a single user.

  ## Examples

      iex> get_user(id)
      {:ok, %User{}}

      iex> get_user(bad_id)
      {:error, :not_found}
  """
  def get_user(id) do
    case Repo.get(User, id) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :not_found}
    end
  end

  @spec get_user!(integer()) :: User.t()
  @doc """
  Gets a single user.

  Raises Ecto.NoResultsError if no record was found.

  ## Examples

      iex> get_user!(id)
      %User{}

      iex> get_user!(bad_id)
      Ecto.NoResultsError

  """
  def get_user!(id),
    do: Repo.get!(User, id)

  @spec get_athenticated_user(Plug.Conn.t()) ::
          {:ok, %User{}} | {:error, :unauthorized}
  @doc """
  Get the athenticated user.

  ## Examples

      iex> get_athenticated_user(conn)
      {:ok, %User{}}

      iex> get_athenticated_user(conn)
      {:error, :unauthorized}

  """
  def get_athenticated_user(conn) do
    case BlogBackend.Guardian.Plug.current_resource(conn) do
      %User{} = user -> {:ok, user}
      _ -> {:error, :unauthorized}
    end
  end

  @spec get_user_by_email(String.t()) ::
          {:ok, User.t()} | {:error, :not_found}
  @doc """
  Gets a single user with the given email.

  ## Examples

      iex> get_user_by_email(id)
      {:ok, %User{}}

      iex> get_user_by_email(bad_id)
      {:error, :not_found}
  """
  def get_user_by_email(email) when is_binary(email) do
    query = from(u in User, where: u.email == ^email)

    case Repo.one(query) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :not_found}
    end
  end

  @spec get_user_by_username(String.t()) ::
          {:ok, User.t()} | {:error, :not_found}
  @doc """
  Gets a single user with the given username.

  ## Examples

      iex> get_user_by_username(id)
      {:ok, %User{}}

      iex> get_user_by_username(bad_id)
      {:error, :not_found}
  """
  def get_user_by_username(username) when is_binary(username) do
    query = from(u in User, where: u.username == ^username)

    case Repo.one(query) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :not_found}
    end
  end

  @spec search_user(term()) :: [User.t()]
  @doc """
  Returns an list of users with the given data.

  ## Examples

      iex> search_user("search")
      [%User{}, ...]

  """
  def search_user(search) do
    search_sql = "%#{search}%"

    from(u in User,
      where:
        fragment("? LIKE ?", u.username, ^search_sql) or
          fragment("? LIKE ?", u.email, ^search_sql)
    )
    |> Repo.all()
  end

  @spec update_user(User.t(), map) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset_update(attrs)
    |> Repo.update()
  end

  @spec delete_user(User.t()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @spec change_user(User.t(), map()) :: Ecto.Changeset.t()
  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @spec check_credentials(String.t(), String.t()) ::
          :ok | {:error, :unprocessable_entity}
  @doc """
  Check if email and passord is correct

  ## Examples

      iex> check_credentials(valid_username, valid_password)
      :ok

      iex> check_credentials(invalid_username, invalid_password)
      {:error, :unprocessable_entity}

  """
  def check_credentials(email, plain_text_password)
      when is_binary(email) and is_binary(plain_text_password) do
    query =
      from(u in User,
        where: u.email == ^email,
        select_merge: %{password: u.password}
      )

    case Repo.one(query) do
      user = %User{} ->
        if Argon2.verify_pass(plain_text_password, user.password) do
          :ok
        else
          {:error, :unprocessable_entity}
        end

      nil ->
        Argon2.no_user_verify()
        {:error, :unprocessable_entity}
    end
  end
end
