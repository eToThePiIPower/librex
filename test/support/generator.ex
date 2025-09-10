defmodule Librex.Generator do
  @moduledoc "Data generation for Librex tests"

  use Ash.Generator

  def author(opts \\ []) do
    sequence_prefix = opts[:prefix_name] || "Author"

    after_action =
      if opts[:book_count] do
        fn author ->
          generate_many(book(author_id: author.id), opts[:book_count])
          Ash.load!(author, :books)
        end
      end

    seed_generator(
      %Librex.Library.Author{
        name: sequence(:author_name, &"#{sequence_prefix} #{&1}")
      },
      overrides: opts,
      after_action: after_action
    )
  end

  def book(opts \\ []) do
    author_id =
      opts[:author_id] ||
        once(:default_author_id, fn -> generate(author().id) end)

    seed_generator(
      %Librex.Library.Book{
        title: sequence(:book_title, &"Book #{&1}"),
        year_released: StreamData.integer(-2100..2100),
        author_id: author_id
      },
      overrides: opts
    )
  end

  def user(opts \\ []) do
    changeset_generator(
      Librex.Accounts.User,
      :register_with_password,
      defaults: [
        email: sequence(:user_email, &"user#{&1}@example.com"),
        password: "password",
        password_confirmation: "password"
      ],
      authorize?: false,
      overrides: opts,
      after_action: fn user ->
        role = opts[:role] || :user
        Librex.Accounts.set_user_role!(user, role, authorize?: false)
      end
    )
  end
end
