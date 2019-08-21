require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class ProductsDocumentationTest < DocumentationTest
        resource 'Products'

        setup :set_product

        def set_product
          @product = create_product(
            name: 'Nice Shirt',
            filters:  { size: %w[Small Medium Large], color: 'Blue' },
            variants: [{ sku: 'SKU1', details: { color: 'Blue' }, regular: 2.to_m },
                       { sku: 'SKU2', details: { color: 'Red' }, regular: 3.to_m }],
            details: { size: 'Small', color: 'Red' },
            images: [{ image: product_image_file, option: 'Blue' }]
          )

          # for recommendations
          create_product(
            name: 'Fall Jacket',
            filters:  { size: %w[Small Medium Large], color: 'Blue' },
            variants: [{ sku: 'SKU1', details: { color: 'Blue' }, regular: 2.to_m }],
            details: { size: 'Small' },
            images: [{ image: product_image_file, option: 'Blue' }]
          )
        end

        def test_and_document_show
          description 'Showing a product'
          route storefront_api.product_path(':slug')
          explanation <<-EOS
            This endpoint includes everything you need to render a product
            detail page including, variants, images, and recommendations.
          EOS

          record_request do
            get storefront_api.product_path(@product)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_show_with_sku_param
          description 'Showing a product with a specific SKU selected'
          route storefront_api.product_path(':slug')
          parameter 'sku', 'View products details specifically for this SKU'
          explanation <<-EOS
            This demonstrates how to get product details for a specific SKU.
            This will result in pricing, inventory, and images to match the
            storefront logic for that SKU.
          EOS

          record_request do
            get storefront_api.product_path(@product, sku: 'SKU2')
            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
