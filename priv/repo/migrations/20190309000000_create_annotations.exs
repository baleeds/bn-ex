defmodule Nota.Repo.Migrations.CreateAnnotation do
  use Ecto.Migration

  def change do
    create table(:annotations, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:text, :text)
      add(:verse_id, references(:verses, type: :integer), null: false)
      add(:user_id, references(:users, type: :uuid), null: false)

      add(:last_synced_at, :utc_datetime)
      add(:deleted_at, :utc_datetime)

      timestamps(type: :utc_datetime)
    end

    create(index(:annotations, [:verse_id]))
    create(index(:annotations, [:user_id]))
  end
end
