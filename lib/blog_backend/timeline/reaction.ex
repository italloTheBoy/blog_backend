defmodule BlogBackend.Timeline.Reaction do
  use Ecto.Schema

  alias BlogBackend.Auth.User
  alias BlogBackend.Timeline.{Post, Comment}

  import Ecto.Changeset

  schema "reactions" do
    field :type, :string

    belongs_to :user, User
    belongs_to :post, Post
    belongs_to :comment, Comment

    timestamps()
  end

  @spec changeset(
          %__MODULE__{},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(comment, %{"post_id" => _post_id} = attrs) do
    comment
    |> cast(attrs, [:type, :user_id, :post_id])
    |> do_changeset()
    |> validate_post()
  end

  def changeset(comment, %{"comment_id" => _comment_id} = attrs) do
    comment
    |> cast(attrs, [:type, :user_id, :comment_id])
    |> do_changeset()
    |> validate_comment()
  end

  defp do_changeset(%Ecto.Changeset{} = changeset) do
    changeset
    |> check_constraint(:reaction,
      name: :check_columns_father,
      message: "Reação inválida"
    )
    |> validate_user()
    |> validate_type()
  end

  defp validate_type(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:type], message: "Reação invalida")
    |> validate_inclusion(:type, ["like", "dislike"], message: "Reação invalida")
  end

  defp validate_user(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:user_id], message: "Login necessário")
    |> assoc_constraint(:user, message: "Login inválido")
  end

  defp validate_post(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:post_id], message: "Postagem necessária")
    |> assoc_constraint(:post, message: "Postagem inválida")
    |> unsafe_validate_unique([:user_id, :post_id], BlogBackend.Repo,
      message: "A reação ja existe"
    )
    |> unique_constraint([:user_id, :post_id],
      message: "A reação ja existe"
    )
  end

  defp validate_comment(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:comment_id], message: "Comentario necessário")
    |> assoc_constraint(:comment, message: "Comentario inválido")
    |> unsafe_validate_unique([:user_id, :comment_id], BlogBackend.Repo,
      message: "A reação ja existe"
    )
    |> unique_constraint([:user_id, :comment_id],
      message: "A reação ja existe"
    )
  end
end
