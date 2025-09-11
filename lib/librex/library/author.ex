defmodule Librex.Library.Author do
  @moduledoc "Resource describing an Author of a Book"
  use Ash.Resource,
    otp_app: :librex,
    domain: Librex.Library,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshJsonApi.Resource]

  alias Librex.Library.Book

  json_api do
    type "author"
    derive_filter? false
  end

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

      pagination offset?: true, default_limit: 12
    end
  end

  policies do
    policy action(:create) do
      authorize_if actor_attribute_equals(:role, :admin)
    end

    policy action_type(:read) do
      authorize_if always()
    end

    policy action(:update) do
      authorize_if actor_attribute_equals(:role, :admin)
      authorize_if actor_attribute_equals(:role, :editor)
    end

    policy action(:destroy) do
      authorize_if actor_attribute_equals(:role, :admin)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :biography, :string do
      public? true
    end

    create_timestamp :inserted_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    has_many :books, Book do
      sort year_released: :desc
      public? true
    end
  end

  aggregates do
    count :book_count, :books do
      public? true
    end

    first :latest_book_year, :books, :year_released
    first :cover_image_url, :books, :cover_image_url
  end
end
