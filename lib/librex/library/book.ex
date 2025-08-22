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

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
      constraints max_length: 128
    end

    attribute :year_released, :integer do
      allow_nil? false
      constraints min: -2100, max: 2100
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
end
