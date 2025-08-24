defmodule Librex.Accounts do
  use Ash.Domain,
    otp_app: :librex

  resources do
    resource Librex.Accounts.Token
    resource Librex.Accounts.User
  end
end
