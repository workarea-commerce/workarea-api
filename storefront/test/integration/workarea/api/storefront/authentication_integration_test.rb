require 'test_helper'

module Workarea
  module Api
    module Storefront
      class AuthenticationIntegrationTest < IntegrationTest
        include AuthenticationTest

        setup :set_user

        def set_user
          @user = create_user(password: 'p@assword!')
        end

        def test_authentication
          get storefront_api.account_path
          refute(response.ok?)
          assert_equal(401, response.status)

          post storefront_api.authentication_tokens_path,
            params: { email: @user.email, password: 'p@assword!' }

          token = JSON.parse(response.body)['token']

          get storefront_api.account_path,
            headers: { 'HTTP_AUTHORIZATION' => encode_credentials(token) }

          assert(response.ok?)
          assert_equal(@user.id.to_s, JSON.parse(response.body)['id'])
        end

        def test_expired_token
          post storefront_api.authentication_tokens_path,
            params: { email: @user.email, password: 'p@assword!' }

          token = JSON.parse(response.body)['token']

          expired = (Workarea.config.authentication_token_expiration + 1.day).from_now
          travel_to expired

          get storefront_api.account_path,
            headers: { 'HTTP_AUTHORIZATION' => encode_credentials(token) }

          refute(response.ok?)
          assert_equal(401, response.status)
        end
      end
    end
  end
end
