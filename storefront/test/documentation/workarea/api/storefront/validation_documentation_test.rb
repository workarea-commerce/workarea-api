require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class ValidationDocumentationTest < DocumentationTest
        include OrdersTest

        resource 'Validation Errors'

        def test_showing_validation_errors
          description 'General validation errors'
          route storefront_api.account_path
          explanation <<-EOS
            This demonstrates API responses when invalid data is submitted.
          EOS

          record_request do
            post storefront_api.account_path,
              as: :json,
              params: { email: 'bob@', password: '' }

            assert_equal(422, response.status)
          end
        end

        def test_checkout_validation_errors
          description 'Checkout validation errors'
          route storefront_api.checkout_path(':id')
          explanation <<-EOS
            Due to the more complex nature of checkout updates and data,
            checkout validation errors are returned inline with the resource
            they are coming from as shown below. Note the response status can be
            200 OK, due to some data being persisted properly.
          EOS

          product = create_product(
            id: 'VINTEE',
            name: 'Vintage Tee',
            variants: [
              { sku: 'VT001', regular: 5.to_m },
              { sku: 'VT002', regular: 6.to_m }
            ]
          )

          order = create_order(email: 'sbaker@workarea.com')
          add_item(order, product_id: product.id, sku: 'VT001', quantity: 2)

          record_request do
            patch storefront_api.checkout_path(order),
              as: :json,
              params: {
                email: 'susanb@',
                shipping_address: {
                  first_name: '',
                  last_name: 'Baker',
                  street: '350 Fifth Avenue',
                  city: 'New York',
                  region: 'NY',
                  country: 'US',
                  postal_code: '10118'
                },
                billing_address: {
                  first_name: 'Susan',
                  last_name: 'Baker',
                  street: '',
                  city: 'New York',
                  region: 'NY',
                  country: 'US',
                  postal_code: '10118'
                }
              }

            assert_equal(422, response.status)
          end
        end
      end
    end
  end
end
