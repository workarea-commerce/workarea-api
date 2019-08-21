require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class PromoCodeListsDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Promo Code Lists'

        def sample_attributes
          create_code_list.as_json.except('_id')
        end

        def test_and_document_index
          description 'Listing promo code lists'
          route admin_api.promo_code_lists_path
          parameter :page, 'Current page'
          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { create_code_list }

          record_request do
            get admin_api.promo_code_lists_path,
                  params: { page: 1, sort_by: 'created_at', sort_direction: 'desc' }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a promo code list'
          route admin_api.promo_code_lists_path

          record_request do
            post admin_api.promo_code_lists_path,
                  params: { promo_code_list: sample_attributes },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_show
          description 'Showing a promo code list'
          route admin_api.promo_code_list_path(':id')

          record_request do
            get admin_api.promo_code_list_path(create_code_list.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a promo code list'
          route admin_api.promo_code_list_path(':id')

          record_request do
            patch admin_api.promo_code_list_path(create_code_list.id),
                    params: { promo_code_list: { name: 'foo' } },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_bulk_upsert
          description 'Bulk upserting promo code lists'
          route admin_api.bulk_promo_code_lists_path

          record_request do
            patch admin_api.bulk_promo_code_lists_path,
                    params: { promo_code_lists: [sample_attributes] * 3 },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a promo code list'
          route admin_api.promo_code_list_path(':id')

          record_request do
            delete admin_api.promo_code_list_path(create_code_list.id)
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
