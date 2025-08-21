defmodule Librex.Generator do
  @moduledoc "Data generation for Librex tests"

  use Ash.Generator

  def author(opts \\ []) do
    seed_generator(
      %Librex.Library.Author{name: sequence(:author_name, &"Author #{&1}")},
      overrides: opts
    )
  end
end
