defmodule BlogBackend.Repo.Migrations.AlterPasswordCharSize do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE users ALTER COLUMN password TYPE character varying(97);"
  end
end
