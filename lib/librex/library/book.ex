defmodule Librex.Library.Book do
  @moduledoc "Resource describing an Book belonging to an Book"
  use Ash.Resource,
    otp_app: :librex,
    domain: Librex.Library,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "books"
    repo Librex.Repo

    references do
      reference :author, index?: true, on_delete: :delete
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

  policies do
    bypass actor_attribute_equals(:role, :admin) do
      authorize_if always()
    end

    policy action(:create) do
      authorize_if actor_attribute_equals(:role, :editor)
    end

    policy action_type(:read) do
      authorize_if always()
    end

    policy action([:update, :destroy]) do
      authorize_if expr(^actor(:role) == :editor and created_by_id == ^actor(:id))
    end
  end

  changes do
    change relate_actor(:created_by, allow_nil?: true), on: [:create]
    change relate_actor(:updated_by, allow_nil?: true)
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

    belongs_to :created_by, Librex.Accounts.User
    belongs_to :updated_by, Librex.Accounts.User
  end

  identities do
    identity :unique_book_title_per_author, [:title, :author_id],
      message: "already exists for this author"
  end

  def next_year, do: Date.utc_today().year + 1
end
