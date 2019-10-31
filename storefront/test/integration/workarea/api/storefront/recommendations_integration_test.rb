require 'test_helper'

module Workarea
  module Api
    module Storefront
      class RecommendationsIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTest
        include AuthenticationTest

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

        def test_showing_recommendations_with_authentication
          get storefront_api.recommendations_path,
            headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) }
          result = JSON.parse(response.body)

          assert(response.ok?)
          assert_equal(6, result['products'].count)
          refute_empty(result['products'].first['name'])
        end

        def test_showing_recommendations_with_session_id
          get storefront_api.recommendations_path,
            params: { session_id: @activity.id }
          result = JSON.parse(response.body)

          assert(response.ok?)
          assert_equal(6, result['products'].count)
          refute_empty(result['products'].first['name'])
        end
      end
    end
  end
end
