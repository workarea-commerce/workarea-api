require 'test_helper'

module Workarea
  module Api
    module Admin
      class ShippingServicesIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @sample_attributes = create_shipping_service.as_json.except('_id')
        end

        def test_lists_shipping_services
          shipping_services = [create_shipping_service, create_shipping_service]
          get admin_api.shipping_services_path
          result = JSON.parse(response.body)['shipping_services']

          assert_equal(3, result.length)
          assert_equal(shipping_services.second, Shipping::Service.new(result.first))
          assert_equal(shipping_services.first, Shipping::Service.new(result.second))
        end

        def test_creates_shipping_services
          assert_difference 'Shipping::Service.count', 1 do
            post admin_api.shipping_services_path,
              params: { shipping_service: @sample_attributes }
          end
        end

        def test_shows_shipping_services
          shipping_service = create_shipping_service
          get admin_api.shipping_service_path(shipping_service.id)
          result = JSON.parse(response.body)['shipping_service']
          assert_equal(shipping_service, Shipping::Service.new(result))
        end

        def test_updates_shipping_services
          shipping_service = create_shipping_service
          patch admin_api.shipping_service_path(shipping_service.id),
            params: { shipping_service: { name: 'foo' } }

          assert_equal('foo', shipping_service.reload.name)
        end

        def test_bulk_upserts_shipping_services
          assert_difference 'Shipping::Service.count', 10 do
            patch admin_api.bulk_shipping_services_path,
              params: { shipping_services: [@sample_attributes] * 10 }
          end
        end

        def test_destroys_shipping_services
          shipping_service = create_shipping_service

          assert_difference 'Shipping::Service.count', -1 do
            delete admin_api.shipping_service_path(shipping_service.id)
          end
        end
      end
    end
  end
end
