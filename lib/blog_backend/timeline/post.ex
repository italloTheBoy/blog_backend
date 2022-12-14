defmodule BlogBackend.Timeline.Post do
  use Ecto.Schema

  import Ecto.Changeset

  alias BlogBackend.Timeline.Reaction
  alias BlogBackend.Auth.User
  alias BlogBackend.Timeline.{Post, Comment}

  schema "posts" do
    field :title, :string
    field :body, :string

    belongs_to :user, User

    has_many :comments, Comment
    has_many :reactions, Reaction

    timestamps()
  end

  @type t() :: %Post{
          id: non_neg_integer(),
          user_id: non_neg_integer(),
          user: User.t(),
          comments: [Comment.t()],
          reactions: [Reaction.t()],
          title: String.t(),
          body: String.t()
        }

  @spec changeset(
          %__MODULE__{},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(post = %Post{}, attrs) do
    post
    |> cast(attrs, [:title, :body, :user_id])
    |> validate_required([:title, :body], message: "Preencha este campo")
    |> validate_title()
    |> validate_body()
    |> validate_user()
  end

  defp validate_title(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_length(:title, max: 50, message: "Título miuto longo")
  end

  defp validate_body(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_length(:body, max: 500, message: "Conteúdo miuto longo")
  end

  defp validate_user(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:user_id], message: "Login necessário")
    |> assoc_constraint(:user, message: "Login inválido")
  end
end
