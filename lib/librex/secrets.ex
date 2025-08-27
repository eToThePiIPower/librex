defmodule Librex.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        Librex.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:librex, :token_signing_secret)
  end
end
