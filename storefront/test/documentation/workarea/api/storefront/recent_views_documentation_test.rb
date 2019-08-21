require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class RecentViewsDocumentationTest < DocumentationTest
        include AuthenticationTest

        resource 'Recent views'

        def test_and_document_updating_with_authentication
          description 'Updating recent views with authentication'
          route storefront_api.recent_views_path
          explanation <<-EOS
            Use this endpoint like this to keep a accurate list of recent
            activity by the authenticated customer. Each of the three resources
            being tracked (products, categories, searches) are optional.
          EOS

          user = create_user
          auth = user.authentication_tokens.create!

          record_request do
            patch storefront_api.recent_views_path,
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(auth.token) },
              as: :json,
              params: {
                product_id: '367A8BB9B5',
                category_id: '596e739b021823358aabe9df',
                search: 'shirts'
              }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_updating_by_session_id
          description 'Updating recent views with a session_id'
          route storefront_api.recent_views_path
          parameter 'session_id', 'A unique session_id you keep for an anonymous browser'
          explanation <<-EOS
            You can also use this endpoint to maintain a recent activity for an
            anonymous browser. Use a consistent session_id to maintain
            continuity.
          EOS

          record_request do
            patch storefront_api.recent_views_path,
              as: :json,
              params: {
                session_id: ':session_id',
                product_id: '367A8BB9B5',
                category_id: '596e739b021823358aabe9df',
                search: 'shirts'
              }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_showing_by_authentication
          description 'Showing recent views from authentication'
          route storefront_api.recent_views_path
          explanation <<-EOS
            Display recent views based on the currently authenticated customer.
          EOS

          user = create_user
          auth = user.authentication_tokens.create!

          product = create_product(name: 'Cool Shirt')
          category = create_category(name: 'Shirts')
          activity = create_user_activity(
            product_ids: [product.id],
            category_ids: [category.id],
            searches: ['shirt']
          )

          record_request do
            get storefront_api.recent_views_path,
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(auth.token) }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_showing_by_session_id
          description 'Showing recent views with a session_id'
          route storefront_api.recent_views_path
          parameter 'session_id', 'A unique session_id you keep for an anonymous browser'
          explanation <<-EOS
            Display recent views based on a session_id you've kept for an
            anonymous browser (as opposed to displaying them based on
            authentication).
          EOS

          product = create_product(name: 'Cool Shirt')
          category = create_category(name: 'Shirts')
          activity = create_user_activity(
            product_ids: [product.id],
            category_ids: [category.id],
            searches: ['shirt']
          )

          record_request do
            get storefront_api.recent_views_path,
              params: { session_id: activity.id }

            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
