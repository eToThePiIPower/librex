defmodule Librex.Generator do
  @moduledoc "Data generation for Librex tests"

  use Ash.Generator

  def author(opts \\ []) do
    sequence_prefix = opts[:prefix_name] || "Author"

    seed_generator(
      %Librex.Library.Author{
        name: sequence(:author_name, &"#{sequence_prefix} #{&1}")
      },
      overrides: opts
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
end
