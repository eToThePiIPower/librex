defmodule LibrexWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [Librex.Library, Librex.Accounts],
    open_api: "/open_api"
end
