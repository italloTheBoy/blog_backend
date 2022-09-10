defmodule BlogBackend.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :username, :string
    field :password, :string, redact: true, virtual: true
    field :hashed_password, :string, redact: true

    timestamps()
  end

  @spec changeset(
          {map, map}
          | %{
              :__struct__ => atom | %{:__changeset__ => map, optional(any) => any},
              optional(atom) => any
            },
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any},
          keyword
        ) :: Ecto.Changeset.t()
  @doc """
  The BlogBackend.Auth.User changeset function"

  """
  def changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:username, :password, :email])
    |> validate_email()
    |> validate_username()
    |> validate_password()
    |> hash_password(opts)
  end

  @spec validate_email(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  @doc """
  Recives an Ecto.Changeset and check if his :email field is valid.

  """
  def validate_email(changeset = %Ecto.Changeset{}) do
    changeset
    |> validate_required([:email], message: "email requerido")
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/,
      message: "email possui espaços ou não possui um @"
    )
    |> validate_length(:email, max: 160, message: "email longo demais")
    |> unsafe_validate_unique(:email, BlogBackend.Repo, message: "email em uso")
    |> unique_constraint(:email, message: "email em uso")
  end

  @spec validate_username(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  @doc """
  Recives an Ecto.Changeset and check if his :username field is valid.

  """
  def validate_username(changeset = %Ecto.Changeset{}) do
    changeset
    |> validate_required([:username], message: "nome de usuario requerido")
    |> validate_format(:username, ~r/^[\S][\w]+$/,
      message: "nome de usuario contem espaços ou caracteres especiais"
    )
    |> validate_length(:username, max: 20, message: "nome de usuario longo demais")
    |> unsafe_validate_unique(:username, BlogBackend.Repo, message: "nome de usuario em uso")
    |> unique_constraint(:username, message: "nome de usuario em uso")
  end

  @spec validate_password(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  @doc """
  Recives an Ecto.Changeset and check if his :password field is valid.

  """
  def validate_password(changeset = %Ecto.Changeset{}) do
    changeset
    |> validate_required([:password], message: "senha requerida")
    |> validate_length(:password, min: 7, count: :bytes, message: "senha curta demais")
    |> validate_length(:password, max: 72, count: :bytes, message: "senha longa demais")
  end

  @spec hash_password(Ecto.Changeset.t(), Array.t()) :: Ecto.Changeset.t()
  @doc """
  Recives a Ecto.Changeset and hash his :password field

  """
  def hash_password(changeset = %Ecto.Changeset{}, opts \\ []) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end
end
