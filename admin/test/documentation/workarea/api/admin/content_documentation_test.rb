require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class ContentDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Content'

        def sample_attributes
          create_content
            .as_json
            .except('_id', 'slug', 'last_indexed_at')
        end

        def test_and_document_index
          description 'Listing content'
          route admin_api.content_index_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { create_content }

          record_request do
            get admin_api.content_index_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' },
                  as: :json

            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating content'
          route admin_api.content_index_path

          record_request do
            post admin_api.content_index_path,
                  params: { content: sample_attributes },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_show
          description 'Showing content'
          route admin_api.content_path(':id')

          record_request do
            get admin_api.content_path(create_content.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating content'
          route admin_api.content_path(':id')

          record_request do
            patch admin_api.content_path(create_content.id),
                    params: { content: { browser_title: 'foo' } },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_bulk_upsert
          description 'Bulk upserting content'
          route admin_api.bulk_content_index_path

          record_request do
            patch admin_api.bulk_content_index_path,
                    params: { content: [sample_attributes] * 3 },
                    as: :json

            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
