require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class ShippingRatesDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Shipping Rates'

        def shipping_service
          @shipping_service ||= create_shipping_service
        end

        def sample_attributes
          shipping_service.rates.first.as_json.except('_id')
        end

        def create_rate
          shipping_service.rates.create!(sample_attributes)
        end

        def test_and_document_index
          description 'Listing shipping rates'
          route admin_api.shipping_service_rates_path(':shipping_service_id')

          2.times { create_rate }

          record_request do
            get admin_api.shipping_service_rates_path(shipping_service.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a shipping rate'
          route admin_api.shipping_service_rates_path(':shipping_service_id')

          record_request do
            post admin_api.shipping_service_rates_path(shipping_service.id),
                  params: { rate: sample_attributes },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a shipping rate'
          route admin_api.shipping_service_rate_path(':shipping_service_id', ':id')

          rate = create_rate

          record_request do
            patch admin_api.shipping_service_rate_path(shipping_service.id, rate.id),
                    params: { rate: { price: 34 } },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a shipping rate'
          route admin_api.shipping_service_rate_path(':shipping_service_id', ':id')

          rate = create_rate

          record_request do
            delete admin_api.shipping_service_rate_path(shipping_service.id, rate.id)
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
