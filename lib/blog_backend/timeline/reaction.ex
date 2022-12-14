defmodule BlogBackend.Timeline.Reaction do
  use Ecto.Schema

  import Ecto.Changeset

  alias BlogBackend.Timeline.Reaction
  alias BlogBackend.Auth.User
  alias BlogBackend.Timeline.{Post, Comment}

  schema "reactions" do
    field :type, :string

    belongs_to :user, User
    belongs_to :post, Post
    belongs_to :comment, Comment

    timestamps()
  end

  @type t() :: %Reaction{
          id: non_neg_integer,
          user_id: non_neg_integer,
          post_id: non_neg_integer,
          comment_id: non_neg_integer,
          user: User.t(),
          post: Post.t(),
          comment: Comment.t(),
          type: String.t()
        }

  @permitted_columns [:user_id, :post_id, :comment_id, :type]

  @doc false
  @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t()
  def changeset(comment, attrs \\ %{}) do
    comment
    |> cast(attrs, @permitted_columns)
    |> validate_assocs()
    |> validate_type()
  end

  defp validate_type(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:type], message: "Tipo de reação requerida")
    |> validate_inclusion(:type, ["like", "dislike"], message: "Tipo de reação invalida")
  end

  defp validate_user(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:user_id], message: "Login necessário")
    |> assoc_constraint(:user, message: "Login inválido")
  end

  defp validate_post(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:post_id], message: "Postagem pai requerida")
    |> assoc_constraint(:post, message: "Postagem pai inválida")
    |> unsafe_validate_unique([:user_id, :post_id], BlogBackend.Repo,
      message: "A reação ja existe"
    )
    |> unique_constraint([:user_id, :post_id],
      message: "A reação ja existe"
    )
  end

  defp validate_comment(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:comment_id], message: "Comentario pai requerido")
    |> assoc_constraint(:comment, message: "Comentario pai inválido")
    |> unsafe_validate_unique([:user_id, :comment_id], BlogBackend.Repo,
      message: "A reação ja existe"
    )
    |> unique_constraint([:user_id, :comment_id],
      message: "A reação ja existe"
    )
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
    |> check_constraint(:reaction,
      name: :check_columns_father,
      message: "Reação inválida"
    )
    |> validate_father_entity()
  end
end
