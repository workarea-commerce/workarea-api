require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class GlobalFunctionalityDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Global Functionality'

        def test_and_document_locale
          description 'Dealing with locales'
          route admin_api.products_path
          parameter :locale, 'I18n locale key'

          product = create_product

          set_locales(available: [:en, :es], default: :en, current: :es)
          product.update!(name: 'Producto de prueba')

          record_request do
            get admin_api.products_path,
              params: {
                locale: 'en'
              }

            assert_equal(200, response.status)
          end

          record_request do
            get admin_api.products_path,
              params: {
                locale: 'es'
              }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_filtered_by_updated_at
          description 'Filtering by updated time stamp'
          route admin_api.products_path
          parameter :updated_at_starts_at, 'Start of a last updated at date range'
          parameter :updated_at_ends_at, 'End of a last updated at date range'

          2.times { create_product }

          record_request do
            get admin_api.products_path,
                  params: {
                    updated_at_starts_at: 1.day.ago,
                    updated_at_ends_at: 1.day.from_now
                  }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_filtered_by_created_at
          description 'Filtering by created at time stamp'
          route admin_api.products_path

          parameter :created_at_starts_at, 'Start of a created at date range'
          parameter :created_at_ends_at, 'End of a created at date range'


          2.times { create_product }

          record_request do
            get admin_api.products_path,
                  params: {
                    created_at_starts_at: 1.day.ago,
                    created_at_ends_at: 1.day.from_now
                  }
            assert_equal(200, response.status)
          end
        end

        def test_and_document_sorting
          description 'Sorting results'
          route admin_api.products_path

          parameter :sort_by, 'Field on which to sort (see responses for possible values)'
          parameter :sort_direction, 'Direction to sort (asc or desc)'

          2.times { create_product }

          record_request do
            get admin_api.products_path,
                  params: {
                    sort_by: 'created_at',
                    sort_direction: 'desc',
                  }
            assert_equal(200, response.status)
          end
        end

        def test_and_document_pagination
          description 'Paging results'
          route admin_api.products_path

          parameter :page, 'Current page'

          2.times { create_product }

          record_request do
            get admin_api.products_path,
                  params: {
                    page: 1
                  }
            assert_equal(200, response.status)
          end
        end

        def test_and_document_additional_pages
          description 'Retrieving addtional pages of results'
          route admin_api.products_path

          parameter :page, 'Current page'

          Workarea.with_config do |config|
            config.per_page = 2

            3.times { create_product }
            record_request do
              get admin_api.products_path,
                    params: {
                      page: 2
                    }
              assert_equal(200, response.status)
            end
          end
        end

      end
    end
  end
end
