require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class RecommendationsDocumentationTest < DocumentationTest
        include AuthenticationTest

        resource 'Personalized Recommendations'

        setup :set_auth
        setup :set_products
        setup :set_user_activity

        def set_auth
          user = create_user
          @auth = user.authentication_tokens.create!
        end

        def set_products
          10.times { create_product }

          top_products = Catalog::Product.sample(10).map { |p| { 'product_id' => p.id } }
          create_top_products(results: top_products)
        end

        def set_user_activity
          @activity = create_user_activity
        end

        def test_and_document_showing_by_authentication
          description 'Showing recommendations with authentication'
          route storefront_api.recommendations_path
          explanation <<-EOS
            Display personalized recommendations based on the currently
            authenticated customer.
          EOS

          record_request do
            get storefront_api.recommendations_path,
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_showing_by_session_id
          description 'Showing recommendations with a session ID'
          route storefront_api.recommendations_path
          parameter 'session_id', 'A unique session_id you keep for an anonymous browser'
          explanation <<-EOS
            Display personalized recommendations based on a session ID that
            you've maintained for an anonymous browser (as opposed to
            authentication).
          EOS

          record_request do
            get storefront_api.recommendations_path,
              params: { session_id: @activity.id }

            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
