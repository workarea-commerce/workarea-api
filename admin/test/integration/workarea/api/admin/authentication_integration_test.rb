require 'test_helper'

module Workarea
  module Api
    module Admin
      class AuthenticationIntegrationTest < IntegrationTest
        def encode_credentials(*args)
          ActionController::HttpAuthentication::Basic.encode_credentials(*args)
        end

        def test_requires_basic_authentication
          get admin_api.products_path
          assert_equal(401, response.status)
        end

        def test_only_allows_admin_users_with_api_access
          user = create_user(admin: false, password: 'Ap1_test')
          admin = create_user(admin: true, password: 'Ap1_test')
          admin_with_api = create_user(
            admin: true,
            password: 'Ap1_test',
            api_access: true
          )

          get admin_api.products_path,
            headers: {
              'HTTP_AUTHORIZATION' => encode_credentials(user.email, 'Ap1_test')
            }
          assert_equal(401, response.status)

          get admin_api.products_path,
            headers: {
              'HTTP_AUTHORIZATION' => encode_credentials(admin.email, 'Ap1_test')
            }
          assert_equal(401, response.status)

          get admin_api.products_path,
            headers: {
              'HTTP_AUTHORIZATION' => encode_credentials(admin_with_api.email, 'Ap1_test')
            }
          assert_equal(200, response.status)
        end

        def test_allows_super_admins
          super_admin = create_user(
            admin: false,
            super_admin: true,
            api_access: false,
            password: 'Ap1_test'
          )

          get admin_api.products_path,
            headers: {
              'HTTP_AUTHORIZATION' => encode_credentials(super_admin.email, 'Ap1_test')
            }
          assert_equal(200, response.status)
        end
      end
    end
  end
end
