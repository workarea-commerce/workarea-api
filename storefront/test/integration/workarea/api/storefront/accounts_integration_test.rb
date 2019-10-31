require 'test_helper'

module Workarea
  module Api
    module Storefront
      class AccountsIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTest
        include AuthenticationTest

        def test_show
          set_current_user(create_user(first_name: 'Ben', last_name: 'Crouse'))
          get storefront_api.account_path

          results = JSON.parse(response.body)
          assert_equal('Ben', results['first_name'])
          assert_equal('Crouse', results['last_name'])
        end

        def test_create
          assert_difference 'User.count', 1 do
            post storefront_api.account_path,
              params: { email: 'bcrouse@weblinc.com', password: 'aP@ssw0rd!' }
          end

          assert(response.ok?)
          results = JSON.parse(response.body)

          assert_equal('bcrouse@weblinc.com', results['account']['email'])
          assert(results['authentication_token'].present?)
        end

        def test_update
          user = create_user(first_name: 'Ben', last_name: 'Crouse')
          set_current_user(user)

          put storefront_api.account_path,
            params: { first_name: 'Bob', last_name: 'Clams' }

          results = JSON.parse(response.body)
          assert_equal('Bob', results['first_name'])
          assert_equal('Clams', results['last_name'])

          user.reload
          assert_equal('Bob', user.first_name)
          assert_equal('Clams', user.last_name)
        end
      end
    end
  end
end
