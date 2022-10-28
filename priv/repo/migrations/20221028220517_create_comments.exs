defmodule BlogBackend.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :body, :varchar, null: false, size: 280

      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :post_id, references(:posts, on_delete: :delete_all)
      add :comment_id, references(:comments, on_delete: :delete_all)

      timestamps()
    end

    create constraint(
             :comments,
             :comments_has_an_unique_father,
             check:
               "(post_id IS NULL AND comment_id IS NOT NULL) OR (comment_id IS NULL AND post_id IS NOT NULL)"
           )
  end
end
