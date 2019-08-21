require 'test_helper'

module Workarea
  module Api
    module Admin
      class CategoriesIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @sample_attributes = create_category.as_json.except('_id', 'slug')
        end

        def test_lists_categories
          categories = [create_category, create_category]
          get admin_api.categories_path
          result = JSON.parse(response.body)['categories']

          assert_equal(3, result.length)
          assert_equal(categories.second, Catalog::Category.new(result.first))
          assert_equal(categories.first, Catalog::Category.new(result.second))

          travel_to 1.week.from_now

          get admin_api.categories_path(
            updated_at_starts_at: 5.days.ago,
            updated_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['categories']

          assert_equal(0, result.length)

          get admin_api.categories_path(
            created_at_starts_at: 5.days.ago,
            created_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['categories']

          assert_equal(0, result.length)

          get admin_api.categories_path(
            updated_at_starts_at: 8.days.ago,
            updated_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['categories']
          assert_equal(3, result.length)

          get admin_api.categories_path(
            created_at_starts_at: 8.days.ago,
            created_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['categories']
          assert_equal(3, result.length)
        end

        def test_creates_categories
          data = @sample_attributes
          assert_difference 'Catalog::Category.count', 1 do
            post admin_api.categories_path, params: { category: data }
          end
        end

        def test_shows_categories
          category = create_category
          get admin_api.category_path(category.id)
          result = JSON.parse(response.body)['category']
          assert_equal(category, Catalog::Category.new(result))
        end

        def test_updates_categories
          category = create_category
          patch admin_api.category_path(category.id), params: { category: { name: 'foo' } }

          category.reload
          assert_equal('foo', category.name)
        end

        def test_bulk_upserts_categories
          data = [@sample_attributes] * 10
          assert_difference 'Catalog::Category.count', 10 do
            patch admin_api.bulk_categories_path, params: { categories: data }
          end
        end

        def test_destroys_categories
          category = create_category

          assert_difference 'Catalog::Category.count', -1 do
            delete admin_api.category_path(category.id)
          end
        end
      end
    end
  end
end
