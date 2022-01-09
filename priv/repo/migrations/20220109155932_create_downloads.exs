defmodule Offsite.Repo.Migrations.CreateDownloads do
  use Ecto.Migration

  def change do
    create table(:downloads) do

      timestamps()
    end
  end
end
