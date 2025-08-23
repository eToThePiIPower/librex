defmodule LibrexWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [Librex.Library],
    open_api: "/open_api"
end
