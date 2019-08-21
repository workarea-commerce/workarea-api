require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class ContentAssetsDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Content Assets'

        def sample_attributes
          create_asset.as_json.except('_id')
        end

        def test_and_document_index
          description 'Listing content assets'
          route admin_api.content_assets_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { create_asset }

          record_request do
            get admin_api.content_assets_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a content asset'
          route admin_api.content_assets_path

          record_request do
            post admin_api.content_assets_path,
                  params: { asset: sample_attributes },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_show
          description 'Showing a content asset'
          route admin_api.content_asset_path(':id')

          record_request do
            get admin_api.content_asset_path(create_asset.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a content asset'
          route admin_api.content_asset_path(':id')

          record_request do
            patch admin_api.content_asset_path(create_asset.id),
                    params: { asset: sample_attributes },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_bulk_upsert
          description 'Bulk upserting content assets'
          route admin_api.bulk_content_assets_path

          record_request do
            patch admin_api.bulk_content_assets_path,
                    params: { assets: [sample_attributes] * 3 },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a content asset'
          route admin_api.content_asset_path(':id')

          record_request do
            delete admin_api.content_asset_path(create_asset.id)
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
