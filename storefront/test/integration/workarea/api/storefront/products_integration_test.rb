require 'test_helper'

module Workarea
  module Api
    module Storefront
      class ProductsIntegrationTest < Workarea::IntegrationTest
        setup :set_product

        def set_product
          @product = create_product(
            filters:  { size: %w[Small Medium Large], color: 'Blue' },
            variants: [{ sku: 'SKU1', details: { color: 'Blue' }, regular: 2.to_m },
                       { sku: 'SKU2', details: { color: 'Red' }, regular: 3.to_m }],
            details: { size: 'Small', color: 'Red' },
            images: [{ image: product_image_file, option: 'Blue' }]
          )

          # for recommendations
          create_top_products(results: [{ 'product_id' => create_product.id }])
        end

        def test_shows_products
          get storefront_api.product_path(@product)
          results = JSON.parse(response.body)
          product = results['product']
          recommendations = results['recommendations']

          assert_equal(1, recommendations.size)

          assert_equal(@product.id, product['id'])
          assert_equal(2, product['variants'].count)
          assert_equal(200.0, product['original_min_price']['cents'])

          processors = product['images'].first['urls'].map { |p| p['type'].to_sym }
          processors.each do |processor|
            refute_includes(Workarea.config.api_product_image_jobs_blacklist, processor)
          end
        end

        def test_shows_products_with_sku_selected
          get storefront_api.product_path(@product, sku: 'SKU2')
          result = JSON.parse(response.body)['product']

          assert_equal(@product.id, result['id'])
          assert_equal(300.0, result['original_min_price']['cents'])
        end
      end
    end
  end
end
