defmodule Librex.Library.Author do
  use Ash.Resource, otp_app: :librex, domain: Librex.Library, data_layer: AshPostgres.DataLayer

  postgres do
    table "authors"
    repo Librex.Repo
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:name, :biography]
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :biography, :string

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end
end
