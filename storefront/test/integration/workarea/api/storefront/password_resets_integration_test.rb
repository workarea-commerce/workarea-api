require 'test_helper'

module Workarea
  module Api
    module Storefront
      class PasswordResetsIntegrationTest < Workarea::IntegrationTest
        def test_forgotten_passwords_emails
          user = create_user(password: 'p@assword!')

          assert_difference 'User::PasswordReset.count', 1 do
            post storefront_api.password_resets_path,
              params: { email: user.email }
          end

          assert_equal(user, User::PasswordReset.first.user)
        end
      end
    end
  end
end
