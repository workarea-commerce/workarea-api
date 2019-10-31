require 'test_helper'

module Workarea
  module Api
    module Storefront
      class RecentViewsIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTest
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

          Metrics::User.save_affinity(
            id: user.email,
            action: 'viewed',
            product_ids: [@product.id],
            category_ids: [@category.id],
            at: Time.current,
            search_ids: %w(foo)
          )

          get storefront_api.recent_views_path

          assert(response.ok?)
          result = JSON.parse(response.body)

          assert_equal(user.email, result['id'])
          assert_equal(@product.id, result['products'].first['id'])
          assert_equal(@category.id.to_s, result['categories'].first['id'])
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

          user_activity = Workarea::Storefront::UserActivityViewModel.wrap(
            Metrics::User.first
          )
          assert_equal(user.email, user_activity.id)
          assert_includes(user_activity.products, @product)
          assert_includes(user_activity.categories, @category)
        end

        def test_showing_recent_views_with_session_id
          Metrics::User.save_affinity(
            id: BSON::ObjectId.new.to_s,
            action: 'viewed',
            product_ids: [@product.id],
            category_ids: [@category.id],
            search_ids: %w(foo)
          )
          activity = Metrics::User.last

          get storefront_api.recent_views_path,
            params: { session_id: activity.id }

          assert_response(:success)
          result = JSON.parse(response.body)

          assert_equal(activity.id.to_s, result['id'])
          assert_equal(@product.id.to_s, result['products'].first['id'])
          assert_equal(@category.id.to_s, result['categories'].first['id'])
        end

        def test_adding_recent_views_for_session_id
          patch storefront_api.recent_views_path,
            params: {
              session_id: BSON::ObjectId.new.to_s,
              product_id: @product.id,
              category_id: @category.id,
              search: 'bar'
            }

          assert_response(:success)

          user_activity = Workarea::Storefront::UserActivityViewModel.wrap(
            Metrics::User.first
          )
          assert_includes(user_activity.products, @product)
          assert_includes(user_activity.categories, @category)
        end

        def test_adding_without_id
          patch storefront_api.recent_views_path,
            params: {
              product_id: @product.id,
              category_id: @category.id,
              search: 'search'
            }

          refute(response.ok?)
          assert_equal(0, Metrics::User.count)
        end
      end
    end
  end
end
