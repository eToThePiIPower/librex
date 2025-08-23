defmodule Librex.Library.Author do
  use Ash.Resource, otp_app: :librex, domain: Librex.Library, data_layer: AshPostgres.DataLayer

  postgres do
    table "authors"
    repo Librex.Repo

    custom_indexes do
      index "name gin_trgm_ops", name: "authors_name_gin_index", using: "GIN"
    end
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:name, :biography]

    read :search do
      argument :query, :ci_string do
        constraints allow_empty?: true
        default ""
      end

      filter expr(contains(name, ^arg(:query)))
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :biography, :string

    create_timestamp :inserted_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    has_many :books, Librex.Library.Book do
      sort year_released: :desc
    end
  end
end
