defmodule BlogBackend.Timeline.Post do
  use Ecto.Schema

  import Ecto.Changeset

  alias BlogBackend.Auth.User

  schema "posts" do
    field :text, :string
    field :title, :string

    belongs_to :user, User

    timestamps()
  end

  @spec changeset(
          %BlogBackend.Timeline.Post{},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(post = %__MODULE__{}, attrs) do
    post
    |> cast(attrs, [:title, :text])
    |> validate_required([:title, :text])
  end
end
