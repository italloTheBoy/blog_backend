defmodule BlogBackend.Repo.Migrations.CreateReactions do
  use Ecto.Migration

  def change do
    create table(:reactions) do
      add :type, :varchar, null: false, size: 7

      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :post_id, references(:posts, on_delete: :delete_all)
      add :comment_id, references(:comments, on_delete: :delete_all)

      timestamps()
    end

    create constraint(
             :reactions,
             :check_reaction_type,
             check: "type IN ('like', 'dislike')"
           )

    create constraint(
             :reactions,
             :check_columns_father,
             check:
               "(post_id IS NULL AND comment_id IS NOT NULL) OR (comment_id IS NULL AND post_id IS NOT NULL)"
           )
  end
end
