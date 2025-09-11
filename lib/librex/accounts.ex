defmodule Librex.Accounts do
  @moduledoc "Module for Identity, Authentication, & Authorization"
  use Ash.Domain, otp_app: :librex, extensions: [AshJsonApi.Domain]

  json_api do
    routes do
      base_route "/users", Librex.Accounts.User do
        post :register_with_password do
          route "/register"

          metadata fn _subject, user, _request ->
            %{token: user.__metadata__.token}
          end
        end

        post :sign_in_with_password do
          route "/sign-in"

          metadata fn _subject, user, _request ->
            %{token: user.__metadata__.token}
          end
        end
      end
    end
  end

  resources do
    resource Librex.Accounts.Token

    resource Librex.Accounts.User do
      define :set_user_role, action: :set_role, args: [:role]
      define :get_user_by_email, action: :get_by_email, args: [:email]
    end
  end
end
