require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class PagesDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Pages'

        def sample_attributes
          create_page.as_json.except('_id', 'slug')
        end

        def test_and_document_index
          description 'Listing pages'
          route admin_api.pages_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { create_page }

          record_request do
            get admin_api.pages_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a page'
          route admin_api.pages_path

          record_request do
            post admin_api.pages_path, params: sample_attributes, as: :json
            assert_equal(201, response.status)
          end
        end

        def test_and_document_show
          description 'Showing a page'
          route admin_api.page_path(':id')

          record_request do
            get admin_api.page_path(create_page.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a page'
          route admin_api.page_path(':id')

          record_request do
            patch admin_api.page_path(create_page.id),
                    params: sample_attributes,
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_bulk_upsert
          description 'Bulk upserting pages'
          route admin_api.bulk_pages_path

          record_request do
            patch admin_api.bulk_pages_path,
                    params: { pages: [sample_attributes] * 3 },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a page'
          route admin_api.page_path(':id')

          page = create_page

          record_request do
            delete admin_api.page_path(page.id), as: :json
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
