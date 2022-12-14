defmodule BlogBackend.Auth.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Argon2
  alias BlogBackend.Timeline.{Post, Comment, Reaction}

  schema "users" do
    field :email, :string
    field :username, :string
    field :password, :string, redact: true, load_in_query: false

    has_many :posts, Post
    has_many :comments, Comment
    has_many :reactions, Reaction

    timestamps()
  end

  @type t() :: %__MODULE__{
          comments: [Comment.t()],
          email: String.t(),
          id: non_neg_integer,
          password: String.t(),
          posts: [Post.t()],
          username: String.t()
        }

  @doc """
  The BlogBackend.Auth.User changeset function"
  """
  @spec changeset(
          %__MODULE__{},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def changeset(user = %__MODULE__{}, attrs) do
    user
    |> cast(attrs, [:username, :password, :email])
    |> validate_required([:password, :username, :email], message: "prencha este campo")
    |> validate_email()
    |> validate_username()
    |> validate_password()
    |> hash_password()
  end

  @spec changeset_update(%__MODULE__{}, map()) :: Ecto.Changeset.t()
  @doc """
  The BlogBackend.Auth.User changeset function to update data
  """
  def changeset_update(user, attrs) do
    user
    |> cast(attrs, [:username, :password, :email])
    |> validate_email()
    |> validate_username()
    |> validate_password()
    |> hash_password()
  end

  @spec validate_email(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_email(changeset) do
    changeset
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/,
      message: "email possui espaços ou não possui um @"
    )
    |> validate_length(:email, max: 160, message: "email longo demais")
    |> unsafe_validate_unique(:email, BlogBackend.Repo, message: "email em uso")
    |> unique_constraint(:email, message: "email em uso")
  end

  @spec validate_username(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_username(changeset) do
    changeset
    |> validate_required([:username], message: "nome de usuario requerido")
    |> validate_format(:username, ~r/^[\S][\w]+$/,
      message: "Username contém espaços ou caracteres especiais."
    )
    |> validate_length(:username, max: 20, message: "Nome de usuario longo demais.")
    |> unsafe_validate_unique(:username, BlogBackend.Repo, message: "Nome de usuario em uso.")
    |> unique_constraint(:username, message: "Nome de usuario em uso.")
  end

  @spec validate_password(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_password(changeset) do
    changeset
    |> validate_length(:password, min: 6, message: "senha curta demais")
    |> validate_length(:password, max: 20, message: "senha longa demais")
    |> validate_confirmation(:password, message: "as senhas não batem")
  end

  @spec hash_password(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp hash_password(changeset = %Ecto.Changeset{valid?: true, changes: %{password: password}}) do
    change(changeset, password: Argon2.hash_pwd_salt(password))
  end

  defp hash_password(changeset), do: changeset
end
