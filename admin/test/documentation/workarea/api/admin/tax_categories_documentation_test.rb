require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class TaxCategoriesDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Tax Categories'

        def sample_attributes
          @count ||= 0
          @count += 1

          create_tax_category.as_json.except('_id').merge('code' => "00#{@count}")
        end

        def test_and_document_index
          description 'Listing tax categories'
          route admin_api.tax_categories_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { create_tax_category }

          record_request do
            get admin_api.tax_categories_path
            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a tax category'
          route admin_api.tax_categories_path

          record_request do
            post admin_api.tax_categories_path,
                  params: { tax_category: sample_attributes },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_show
          description 'Showing a tax category'
          route admin_api.tax_category_path(':id')

          record_request do
            get admin_api.tax_category_path(create_tax_category.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a tax categories'
          route admin_api.tax_category_path(':id')

          record_request do
            patch admin_api.tax_category_path(create_tax_category.id),
                  params: { tax_category: { name: 'foo' } },
                  as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_bulk_upsert
          description 'Bulk upserting tax categories'
          route admin_api.bulk_tax_categories_path

          record_request do
            patch admin_api.bulk_tax_categories_path,
                    params: { tax_categories: [sample_attributes] * 3 },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a tax category'
          route admin_api.tax_category_path(':id')

          record_request do
            delete admin_api.tax_category_path(create_tax_category.id)
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
