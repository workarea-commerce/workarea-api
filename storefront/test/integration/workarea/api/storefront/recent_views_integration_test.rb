require 'test_helper'

module Workarea
  module Api
    module Storefront
      class RecentViewsIntegrationTest < IntegrationTest
        include AuthenticationTest

        setup :set_product
        setup :set_category

        def set_product
          @product = create_product
        end

        def set_category
          @category = create_category
        end

        def test_showing_recent_views_with_authentication
          user = create_user(first_name: 'Ben', last_name: 'Crouse')
          set_current_user(user)

          activity = create_user_activity(
            id: user.id,
            product_ids: [@product.id],
            category_ids: [@category.id],
            searches: ['foo']
          )

          get storefront_api.recent_views_path

          assert(response.ok?)
          result = JSON.parse(response.body)

          assert_equal(activity.id, result['id'])
          assert_equal(@product.id, result['products'].first['id'])
          assert_equal(@category.id.to_s, result['categories'].first['id'])
          assert_includes(result['searches'], 'foo')
        end

        def test_adding_recent_views_for_authentication
          user = create_user(first_name: 'Ben', last_name: 'Crouse')
          set_current_user(user)
          patch storefront_api.recent_views_path,
            params: {
              product_id: @product.id,
              category_id: @category.id,
              search: 'foo'
            }

          assert(response.ok?)

          user_activity = Recommendation::UserActivity.first
          assert_equal(user.id.to_s, user_activity.id.to_s)
          assert_includes(user_activity.product_ids, @product.id)
          assert_includes(user_activity.category_ids, @category.id.to_s)
          assert_includes(user_activity.searches, 'foo')
        end

        def test_showing_recent_views_with_session_id
          activity = create_user_activity(
            product_ids: [@product.id],
            category_ids: [@category.id],
            searches: ['bar']
          )

          get storefront_api.recent_views_path,
            params: { session_id: activity.id }

          assert(response.ok?)
          result = JSON.parse(response.body)

          assert_equal(activity.id, result['id'])
          assert_equal(@product.id, result['products'].first['id'])
          assert_equal(@category.id.to_s, result['categories'].first['id'])
          assert_includes(result['searches'], 'bar')
        end

        def test_adding_recent_views_for_session_id
          activity = create_user_activity(
            product_ids: [@product.id],
            category_ids: [@category.id],
            searches: ['bar']
          )

          patch storefront_api.recent_views_path,
            params: {
              session_id: activity.id,
              product_id: @product.id,
              category_id: @category.id,
              search: 'bar'
            }

          assert(response.ok?)

          user_activity = Recommendation::UserActivity.first
          assert_equal(activity.id, user_activity.id)
          assert_includes(user_activity.product_ids, @product.id)
          assert_includes(user_activity.category_ids, @category.id.to_s)
          assert_includes(user_activity.searches, 'bar')
        end

        def test_adding_without_id
          patch storefront_api.recent_views_path,
            params: {
              product_id: @product.id,
              category_id: @category.id,
              search: 'search'
            }

          refute(response.ok?)
          assert_equal(0, Recommendation::UserActivity.count)
        end
      end
    end
  end
end
