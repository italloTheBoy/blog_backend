defmodule BlogBackend.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false

  alias Phoenix.LiveView.Plug
  alias BlogBackend.Repo
  alias BlogBackend.Auth.User

  @doc """
  Returns the list of user.

  ## Examples

      iex> list_user()
      [%User{}, ...]

  """
  def list_user do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Return nil if the User does not exist.

  ## Examples

      iex> get_user(id)
      %User{}

      iex> get_user(bad_id)
      nil
  """
  def get_user(id), do: Repo.get(User, id)

  @spec pick_user(non_neg_integer()) ::
          {:ok, Post.t()}
          | {:error, :not_found | :unprocessable_entity}
  @doc """
  Gets a single user.

  ## Examples

      iex> pick_user(id)
      {:ok, %User{}}

      iex> pick_user(bad_id)
      {:error, reason}
  """
  def pick_user(id) do
    case Repo.get(User, id) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :not_found}
    end
  rescue
    _ -> {:error, :unprocessable_entity}
  end

  @doc """
  Gets a single user.

  Raises Ecto.NoResultsError if no record was found.

  ## Examples

      iex> get_user!(id)
      %User{}

      iex> get_user!(bad_id)
      Ecto.NoResultsError

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Get the athenticated user.

  ## Examples

      iex> get_current_user(conn)
      {:ok, %User{}}

      iex> get_current_user(conn)
      {:error, :unauthorized}

  """
  @spec get_current_user(Plug.Conn.t()) :: {:ok, %User{}} | {:error, :unauthorized}
  def get_current_user(conn) do
    case BlogBackend.Guardian.Plug.current_resource(conn) do
      %User{} = user -> {:ok, user}
      _ -> {:error, :unauthorized}
    end
  end

  @spec create_user(:invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}) ::
          any
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

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def auth_user(email, plain_text_password) do
    from(u in User,
      where: u.email == ^email,
      select_merge: %{password: u.password}
    )
    |> Repo.one()
    |> case do
      user = %User{} ->
        if Argon2.verify_pass(plain_text_password, user.password) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end

      nil ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}
    end
  end
end
