require 'test_helper'

module Workarea
  module Api
    module Admin
      class TaxCategoriesIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        def sample_attributes
          @count ||= 0
          @count += 1

          create_tax_category.as_json.except('_id').merge('code' => "00#{@count}")
        end

        def test_lists_tax_categories
          tax_categories = [create_tax_category, create_tax_category]
          get admin_api.tax_categories_path
          result = JSON.parse(response.body)['tax_categories']

          assert_equal(2, result.length)
          assert_equal(tax_categories.second, Tax::Category.new(result.first))
          assert_equal(tax_categories.first, Tax::Category.new(result.second))
        end

        def test_creates_tax_categories
          data = sample_attributes
          assert_difference 'Tax::Category.count', 1 do
            post admin_api.tax_categories_path, params: { tax_category: data }
          end
        end

        def test_shows_tax_categories
          tax_category = create_tax_category
          get admin_api.tax_category_path(tax_category.id)
          result = JSON.parse(response.body)['tax_category']
          assert_equal(tax_category, Tax::Category.new(result))
        end

        def test_updates_tax_categories
          tax_category = create_tax_category
          patch admin_api.tax_category_path(tax_category.id),
            params: { tax_category: { name: 'foo' } }

          assert_equal('foo', tax_category.reload.name)
        end

        def test_bulk_upserts_tax_categories
          data = Array.new(10) { sample_attributes }
          assert_difference 'Tax::Category.count', 10 do
            patch admin_api.bulk_tax_categories_path, params: { tax_categories: data }
          end
        end

        def test_destroys_tax_categories
          tax_category = create_tax_category
          assert_difference 'Tax::Category.count', -1 do
            delete admin_api.tax_category_path(tax_category.id)
          end
        end
      end
    end
  end
end
