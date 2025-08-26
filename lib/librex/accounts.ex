defmodule Librex.Accounts do
  @moduledoc "Module for Identity, Authentication, & Authorization"
  use Ash.Domain,
    otp_app: :librex

  resources do
    resource Librex.Accounts.Token
    resource Librex.Accounts.User do
      define :set_user_role, action: :set_role, args: [:role]
      define :get_user_by_email, action: :get_by_email, args: [:email]
    end
  end
end
