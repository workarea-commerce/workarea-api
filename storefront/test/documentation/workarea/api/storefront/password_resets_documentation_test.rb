require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class PasswordResetsDocumentationTest < DocumentationTest
        resource 'Password Resets'

        def test_and_document_create
          description 'Sending a forgot password email'
          route storefront_api.password_resets_path
          explanation <<-EOS
            This will send a password reset email to the email address if there
            is an account. The email will contain a link to the site where the
            password reset can be completed.
          EOS

          record_request do
            post storefront_api.password_resets_path,
              as: :json,
              params: { email: create_user.email }

            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
