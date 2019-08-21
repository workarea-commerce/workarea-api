require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class NavigationTaxonsDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Navigation taxonomy'

        def sample_attributes
          create_taxon.as_json.except('_id', 'slug')
        end

        def test_and_document_index
          description 'Listing taxons'
          route admin_api.navigation_taxons_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { create_taxon }

          record_request do
            get admin_api.navigation_taxons_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a taxon'
          route admin_api.navigation_taxons_path

          record_request do
            post admin_api.navigation_taxons_path,
                  params: { navigation_taxon: sample_attributes },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_show
          description 'Showing a navigation taxon'
          route admin_api.navigation_taxon_path(':id')

          record_request do
            get admin_api.navigation_taxon_path(create_taxon.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a navigation taxons'
          route admin_api.navigation_taxon_path(':id')

          record_request do
            patch admin_api.navigation_taxon_path(create_taxon.id),
                    params: { navigation_taxon: { name: 'foo' } },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_bulk_upsert
          description 'Bulk upserting navigation taxons'
          route admin_api.bulk_navigation_taxons_path

          record_request do
            patch admin_api.bulk_navigation_taxons_path,
                    params: { navigation_taxons: [sample_attributes] * 3 },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a navigation taxon'
          route admin_api.navigation_taxon_path(':id')

          record_request do
            delete admin_api.navigation_taxon_path(create_taxon.id)
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
