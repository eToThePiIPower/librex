defmodule Librex.Library.Book do
  use Ash.Resource, otp_app: :librex, domain: Librex.Library, data_layer: AshPostgres.DataLayer

  postgres do
    table "books"
    repo Librex.Repo

    references do
      reference :author, index?: true
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:title, :year_released, :cover_image_url, :author_id]
    end

    update :update do
      accept [:title, :year_released, :cover_image_url]
    end
  end

  validations do
    validate numericality(:year_released,
               greater_than_or_equal_to: -2100,
               less_than_or_equal_to: &__MODULE__.next_year/0
             ),
             where: [present(:year_released)],
             message: "must be between 2100 BCE and next year"

    validate match(
               :cover_image_url,
               #  ~r"^nope$"
               ~r"^(https?://|/images/cover/)"
             ),
             where: [changing(:cover_image_url)],
             message: "must start with http[s]:// or /images/cover/"

    validate match(
               :cover_image_url,
               #  ~r"^nope$"
               ~r"(\.png|\.jpg)$"
             ),
             where: [changing(:cover_image_url)],
             message: "must end in .png or .jpg"
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
      constraints max_length: 128
    end

    attribute :year_released, :integer do
      allow_nil? false
    end

    attribute :cover_image_url, :string

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :author, Librex.Library.Author do
      allow_nil? false
    end
  end

  def next_year, do: Date.utc_today().year + 1
end
