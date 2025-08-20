defmodule Librex.Repo do
  use Ecto.Repo,
    otp_app: :librex,
    adapter: Ecto.Adapters.Postgres
end
