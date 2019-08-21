require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class TaxRatesDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Tax Rates'

        def tax_category
          @tax_category ||= create_tax_category
        end

        def sample_attributes
          @sample_attributes ||= tax_category.rates.first.as_json.except('_id')
        end

        def create_rate
          tax_category.rates.create!(sample_attributes)
        end

        def test_and_document_index
          description 'Listing tax rates'
          route admin_api.tax_category_rates_path(':tax_category_id')

          2.times { create_rate }

          record_request do
            get admin_api.tax_category_rates_path(tax_category.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a tax rate'
          route admin_api.tax_category_rates_path(':tax_category_id')

          record_request do
            post admin_api.tax_category_rates_path(tax_category.id),
                  params: { rate: sample_attributes },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a tax rate'
          route admin_api.tax_category_rate_path(':tax_category_id', ':id')

          rate = create_rate

          record_request do
            patch admin_api.tax_category_rate_path(tax_category.id, rate.id),
                    params: { rate: { percentage: 0.04 } },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a tax rate'
          route admin_api.tax_category_rate_path(':tax_category_id', ':id')

          rate = create_rate

          record_request do
            patch admin_api.tax_category_rate_path(tax_category.id, rate.id)
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
