require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class CartsDocumentationTest < DocumentationTest
        include AuthenticationTest
        include OrdersTest

        resource 'Cart'

        setup :set_user, :set_product, :set_order

        def set_user
          @user = create_user(first_name: 'Susan', last_name: 'Baker')
          @auth = @user.authentication_tokens.create!
        end

        def set_product
          @product = create_product(
            id: 'VINTEE',
            name: 'Vintage Tee',
            variants: [
              { sku: 'VT001', regular: 5.to_m },
              { sku: 'VT002', regular: 6.to_m }
            ]
          )

          create_inventory(id: 'VT001', policy: 'standard', available: 2)
        end

        def set_order
          @order = create_order(user_id: @user.id)
          add_item(@order, product_id: @product.id, sku: 'VT001', quantity: 2)
        end

        def test_and_document_listing_carts
          description "Listing user's carts"
          route storefront_api.carts_path
          explanation <<-EOS
            You can get a listing of all of a user's open carts with this
            endpoint. There will usually be one from the standard storefront,
            but with the cart creation endpoint there is the potential to create
            and manage multiple carts for a single user.
          EOS

          record_request do
            get storefront_api.carts_path,
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_creating_a_guest_cart
          description 'Creating a new guest cart'
          route storefront_api.carts_path
          explanation <<-EOS
            Use this endpoint to create a cart. This allows the possibility of
            multiple carts for a user.
          EOS

          record_request do
            post storefront_api.carts_path
            assert_equal(200, response.status)
          end
        end

        def test_and_document_creating_a_logged_in_cart
          description 'Creating a new cart for a user'
          route storefront_api.carts_path
          explanation <<-EOS
            Here's how to create a cart for a user. This endpoint allows the
            possibility of multiple carts for a user.
          EOS

          record_request do
            post storefront_api.carts_path,
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_showing_a_cart
          description 'Showing cart'
          route storefront_api.cart_path(':id')
          explanation <<-EOS
            This will get details on a cart you've created with the cart
            creation endpoint.
          EOS

          record_request do
            get storefront_api.cart_path(@order),
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_adding_a_promo_code
          description 'Adding a promo code'
          route storefront_api.add_promo_code_to_cart_path(':id')
          explanation 'This endpoint will add promo codes to the cart'

          create_order_total_discount(promo_codes: %w(10OFF))

          record_request do
            post storefront_api.add_promo_code_to_cart_path(@order),
              as: :json,
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) },
              params: { promo_code: '10OFF' }

            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
