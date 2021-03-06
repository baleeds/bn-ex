defmodule Nota.Annotations.Annotation do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Nota.Bible.Verse
  alias Nota.Auth.User
  alias Nota.Annotations.AnnotationFavorite

  @required_fields ~w(
    verse_id
    user_id
    text
  )a

  @optional_fields ~w(
    id
    last_synced_at
    inserted_at
    updated_at
    deleted_at
  )a

  @all_fields @required_fields ++ @optional_fields

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "annotations" do
    field(:text, :string)
    field(:last_synced_at, :utc_datetime)
    field(:deleted_at, :utc_datetime)

    field(:is_favorite, :boolean, virtual: true)

    belongs_to(:verse, Verse, type: :integer)
    belongs_to(:user, User)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(annotation, attrs) do
    annotation
    |> cast(attrs, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:verse_id)
    |> foreign_key_constraint(:user_id)
  end

  def projection(nil) do
    from(a in __MODULE__,
      select: %__MODULE__{
        id: a.id,
        text: a.text,
        verse_id: a.verse_id,
        user_id: a.user_id,
        inserted_at: a.inserted_at,
        updated_at: a.updated_at,
        is_favorite: false
      }
    )
  end

  def projection(user_id) do
    from(a in __MODULE__,
      left_join: f in AnnotationFavorite,
      on: f.user_id == ^user_id and f.annotation_id == a.id,
      select: %__MODULE__{
        id: a.id,
        text: a.text,
        verse_id: a.verse_id,
        user_id: a.user_id,
        inserted_at: a.inserted_at,
        updated_at: a.updated_at,
        is_favorite: fragment("? IS NOT NULL", f.id)
      }
    )
  end
end
