defmodule Librex.Support.Helpers do
  @doc "HTML selector for application (not server/client) flash messages."
  def flash(type), do: ":not(#server-error, #client-error) > div#flash-#{type}"

  @doc "HTML selector for field error messages."
  def field_error(name), do: "div[data-fieldset-for='form[#{name}]'] > p.text-error"
end
