defmodule BlogBackend.Timeline.Comment do
  use Ecto.Schema

  alias BlogBackend.Auth.User
  alias BlogBackend.Timeline.Post

  import Ecto.Changeset

  schema "comments" do
    field :body, :string

    belongs_to :user, User
    belongs_to :post, Post
    belongs_to :conmment, __MODULE__

    has_many :comments, __MODULE__

    timestamps()
  end

  @spec changeset(
          %__MODULE__{},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
