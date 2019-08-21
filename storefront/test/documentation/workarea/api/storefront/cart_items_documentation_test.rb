require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class CartItemsDocumentationTest < DocumentationTest
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
        end

        def test_and_document_adding_an_item
          description 'Adding an item'
          route storefront_api.cart_items_path(':cart_id')
          explanation <<-EOS
            Adds an item to the cart. Use the create a cart endpoint to get a
            cart_id to use with this endpoint.
          EOS

          record_request do
            post storefront_api.cart_items_path(@order),
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) },
              as: :json,
              params: {
                product_id: @product.id,
                sku: @product.skus.first,
                quantity: 2
              }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_updating_an_item
          add_item(@order, product_id: @product.id, sku: 'VT001', quantity: 2)

          description 'Updating an item'
          route storefront_api.cart_item_path(':cart_id', ':id')
          explanation <<-EOS
            Updates an item in the cart. Use the create a cart endpoint to get a
            cart ID to use with this endpoint, and use the adding an item
            endpoint to get an ID for an item.
          EOS

          record_request do
            patch storefront_api.cart_item_path(@order, @order.items.first),
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) },
              as: :json,
              params: {
                sku: @product.skus.last,
                quantity: 3
              }

            assert_equal(200, response.status)
          end
        end

        def test_and_document_deleting_an_item
          add_item(@order, product_id: @product.id, sku: 'VT001', quantity: 2)

          description 'Delete an item'
          route storefront_api.cart_item_path(':cart_id', ':id')
          explanation <<-EOS
            Removes an item in the cart. Use the create a cart endpoint to get a
            cart ID to use with this endpoint, and use the adding an item
            endpoint to get an ID for an item.
          EOS

          record_request do
            delete storefront_api.cart_item_path(@order, @order.items.first),
              headers: { 'HTTP_AUTHORIZATION' => encode_credentials(@auth.token) }

            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
