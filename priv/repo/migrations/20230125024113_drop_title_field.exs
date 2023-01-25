defmodule BlogBackend.Repo.Migrations.DropTitleField do
  use Ecto.Migration

  def change do
    alter table("posts") do
      remove :title
    end
  end
end
