require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class ReleasesDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Releases'

        def sample_attributes
          create_release.as_json.except('_id')
        end

        def test_and_document_index
          description 'Listing releases'
          route admin_api.releases_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { create_release }

          record_request do
            get admin_api.releases_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a release'
          route admin_api.releases_path

          record_request do
            post admin_api.releases_path, params: sample_attributes, as: :json
            assert_equal(201, response.status)
          end
        end

        def test_and_document_show
          description 'Showing a release'
          route admin_api.release_path(':id')

          record_request do
            get admin_api.release_path(create_release.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a release'
          route admin_api.release_path(':id')

          record_request do
            patch admin_api.release_path(create_release.id),
                    params: sample_attributes,
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_bulk_upsert
          description 'Bulk upserting releases'
          route admin_api.bulk_releases_path

          record_request do
            patch admin_api.bulk_releases_path,
                    params: { releases: [sample_attributes] * 3 },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a release'
          route admin_api.release_path(':id')

          release = create_release

          record_request do
            delete admin_api.release_path(release.id), as: :json
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
