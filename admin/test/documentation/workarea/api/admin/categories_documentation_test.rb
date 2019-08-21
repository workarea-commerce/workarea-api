require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class CategoriesDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Categories'

        def sample_attributes
          create_category(
            product_rules: [{ name: 'search', operator: 'equals', value: '*' }]
          ).as_json.except('_id', 'slug')
        end

        def test_and_document_index
          description 'Listing categories'
          route admin_api.categories_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times do
            create_category(
              product_rules: [{ name: 'search', operator: 'equals', value: '*' }]
            )
          end

          record_request do
            get admin_api.categories_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }
            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a category'
          route admin_api.categories_path

          record_request do
            post admin_api.categories_path, params: sample_attributes, as: :json
            assert_equal(201, response.status)
          end
        end

        def test_and_document_show
          description 'Showing a category'
          route admin_api.category_path(':id')

          category = create_category(
            product_rules: [{ name: 'search', operator: 'equals', value: '*' }]
          )

          record_request do
            get admin_api.category_path(category.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a category'
          route admin_api.category_path(':id')

          category = create_category(
            product_rules: [{ name: 'search', operator: 'equals', value: '*' }]
          )

          record_request do
            patch admin_api.category_path(category.id),
                    params: sample_attributes,
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_bulk_upsert
          description 'Bulk upserting categories'
          route admin_api.bulk_categories_path

          record_request do
            patch admin_api.bulk_categories_path,
                    params: { categories: [sample_attributes] * 3 },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a category'
          route admin_api.category_path(':id')

          category = create_category

          record_request do
            delete admin_api.category_path(category.id), as: :json
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
