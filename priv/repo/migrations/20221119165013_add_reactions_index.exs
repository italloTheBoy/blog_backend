defmodule BlogBackend.Repo.Migrations.AddReactionsIndex do
  use Ecto.Migration

  def change do
    create index(:reactions, [:user_id])
    create index(:reactions, [:post_id])
    create index(:reactions, [:comment_id])

    create unique_index(:reactions, [:user_id, :post_id])
    create unique_index(:reactions, [:user_id, :comment_id])
  end
end
