defmodule Librex.Library do
  use Ash.Domain, otp_app: :librex, extensions: [AshJsonApi.Domain, AshPhoenix]

  resources do
    resource Librex.Library.Author do
      define :create_author, action: :create
      define :read_authors, action: :read
      define :get_author_by_id, action: :read, get_by: :id
      define :update_author, action: :update
      define :destroy_author, action: :destroy

      define :search_authors,
        action: :search,
        args: [:query],
        default_options: [
          load: [:book_count, :latest_book_year, :cover_image_url]
        ]
    end

    resource Librex.Library.Book do
      define :create_book, action: :create
      define :get_book_by_id, action: :read, get_by: :id
      define :update_book, action: :update
      define :destroy_book, action: :destroy
    end

    forms do
      form :create_book, args: [:author_id]
    end

    resource Librex.Library.Book
  end
end
