defmodule BlogBackend.Timeline.Comment do
  use Ecto.Schema

  alias BlogBackend.Auth.User
  alias BlogBackend.Timeline.Post

  import Ecto.Changeset

  schema "comments" do
    field :body, :string

    belongs_to :user, User
    belongs_to :post, Post
    belongs_to :comment, __MODULE__

    has_many :comments, __MODULE__

    timestamps()
  end

  @spec changeset(
          %__MODULE__{},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(comment, %{"post_id" => _post_id} = attrs) do
    comment
    |> cast(attrs, [:body, :user_id, :post_id])
    |> validate_required([:body], message: "Preencha este campo")
    |> check_constraint(:comment,
      name: :comments_has_an_unique_father,
      message: "Reação inválida"
    )
    |> validate_user()
    |> validate_post()
    |> validate_body()
  end

  def changeset(comment, %{"comment_id" => _comment_id} = attrs) do
    comment
    |> cast(attrs, [:body, :user_id, :comment_id])
    |> validate_required([:body], message: "Preencha este campo")
    |> check_constraint(:comment,
      name: :comments_has_an_unique_father,
      message: "Reação inválida"
    )
    |> validate_user()
    |> validate_comment()
    |> validate_body()
  end

  defp validate_body(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_length(:body, max: 280, message: "Conteúdo miuto longo")
  end

  defp validate_user(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:user_id], message: "Login necessário")
    |> assoc_constraint(:user, message: "Login inválido")
  end

  defp validate_post(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:post_id], message: "Postagem necessário")
    |> assoc_constraint(:post, message: "Postagem inválido")
  end

  defp validate_comment(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:comment_id], message: "Comentario necessário")
    |> assoc_constraint(:comment, message: "Comentario inválido")
  end
end
