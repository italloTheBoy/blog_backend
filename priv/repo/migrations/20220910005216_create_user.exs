defmodule BlogBackend.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false, size: 160
      add :username, :string, null: false, size: 20
      add :hash_password, :string, null: false, size: 72

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:username])
  end
end
