require 'test_helper'

module Workarea
  module Api
    module Storefront
      class AuthenticationTokensIntegrationTest < IntegrationTest
        include AuthenticationTest

        setup :set_user

        def set_user
          @user = create_user(password: 'p@assword!')
        end

        def test_creating_tokens
          post storefront_api.authentication_tokens_path,
            params: { email: @user.email, password: 'p@assword!' }

          assert(response.ok?)
          results = JSON.parse(response.body)
          auth = @user.authentication_tokens.first
          assert_equal(auth.token, results['token'])
          assert_equal(auth.expires_at, results['expires_at'])
        end

        def test_wrong_password
          post storefront_api.authentication_tokens_path,
            params: { email: @user.email, password: 'wrongpassword' }

          refute(response.ok?)
          assert(JSON.parse(response.body)['problem'].present?)
        end

        def test_wrong_email
          post storefront_api.authentication_tokens_path,
            params: { email: 'foo@bar.com', password: 'p@assword!' }

          refute(response.ok?)
          assert(JSON.parse(response.body)['problem'].present?)
        end

        def test_expiring_auth_tokens_when_a_password_changes
          post storefront_api.authentication_tokens_path,
            params: { email: @user.email, password: 'p@assword!' }

          token = JSON.parse(response.body)['token']

          get storefront_api.account_path,
            headers: { 'HTTP_AUTHORIZATION' => encode_credentials(token) }

          assert(response.ok?)

          @user.update_attributes!(password: 'a_different_password')

          get storefront_api.account_path,
            headers: { 'HTTP_AUTHORIZATION' => encode_credentials(token) }

          refute(response.ok?)
        end

        def test_locking_login
          Workarea.config.allowed_login_attempts.times do
            post storefront_api.authentication_tokens_path,
              params: { email: @user.email, password: 'wrongpassword' }
          end

          post storefront_api.authentication_tokens_path,
            params: { email: @user.email, password: 'p@assword!' }

          refute(response.ok?)
          assert(JSON.parse(response.body)['problem'].present?)
        end

        def test_refreshing_token
          post storefront_api.authentication_tokens_path,
            params: { email: @user.email, password: 'p@assword!' }

          token1 = JSON.parse(response.body)
          patch storefront_api.authentication_tokens_path,
            headers: { 'HTTP_AUTHORIZATION' => encode_credentials(token1['token']) }
          token2 = JSON.parse(response.body)
          assert_operator(token2['expires_at'].to_datetime, :>, token1['expires_at'].to_datetime)
        end
      end
    end
  end
end
