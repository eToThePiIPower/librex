defmodule Librex.Library do
  use Ash.Domain, otp_app: :librex, extensions: [AshPhoenix]

  resources do
    resource Librex.Library.Author do
      define :create_author, action: :create
      define :read_authors, action: :read
      define :get_author_by_id, action: :read, get_by: :id
      define :update_author, action: :update
      define :destroy_author, action: :destroy
    end
  end
end
