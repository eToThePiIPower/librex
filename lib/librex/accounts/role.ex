defmodule Librex.Accounts.Role do
  @moduledoc "Definition module for User roles"
  use Ash.Type.Enum, values: [:admin, :editor, :user]
end
