defmodule BlogBackend.Timeline.Comment do
  use Ecto.Schema

  alias BlogBackend.Auth.User
  alias BlogBackend.Timeline.Post

  import Ecto.Changeset

  @permitted_columns [:body, :user_id, :post_id, :comment_id]

  schema "comments" do
    field :body, :string

    belongs_to :user, User
    belongs_to :post, Post
    belongs_to :comment, __MODULE__

    has_many :comments, __MODULE__

    timestamps()
  end

  @type t :: %__MODULE__{
          body: String.t(),
          id: non_neg_integer,
          post: Post.t(),
          post_id: non_neg_integer,
          user: User.t(),
          user_id: non_neg_integer,
          comment: __MODULE__.t(),
          comment_id: non_neg_integer,
          comments: [t],
        }

  @doc false

  @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()

  def changeset(comment, attrs \\ %{}) do
    comment
    |> cast(attrs, @permitted_columns )
    |> validate_assocs()
    |> validate_body()
  end

  defp validate_body(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:body], message: "Insira o conteúdo do commentario")
    |> validate_length(:body, max: 280, message: "Conteúdo miuto longo")
  end

  defp validate_user(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:user_id], message: "Login necessário")
    |> assoc_constraint(:user, message: "Login inválido")
  end

  defp validate_post(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:post_id], message: "Postagem pai necessária")
    |> assoc_constraint(:post, message: "Postagem pai inválida")
  end

  defp validate_comment(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:comment_id], message: "Comentario pai necessário")
    |> assoc_constraint(:comment, message: "Comentario pai inválido")
  end

  defp validate_father_entity(%Ecto.Changeset{} = changeset) do
    comment_id = get_field(changeset, :comment_id)
    post_id = get_field(changeset, :post_id)

    case {comment_id, post_id} do
      {nil, nil} ->
        add_error(changeset, :father_entity, "Entidade pai requerida")

      {nil, _post_id} ->
        validate_post(changeset)

      {_comment_id, nil} ->
        validate_comment(changeset)

      _ ->
        add_error(changeset, :father_entity, "Entidade pai invalida")
    end
  end

  defp validate_assocs(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_user()
    |> check_constraint(:comment,
      name: :comments_has_an_unique_father,
      message: "Comentario inválido"
    )
    |> validate_father_entity()
  end
end
