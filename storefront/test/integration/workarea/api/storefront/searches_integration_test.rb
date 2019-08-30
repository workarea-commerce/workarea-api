require 'test_helper'

module Workarea
  module Api
    module Storefront
      class SearchesIntegrationTest < IntegrationTest
        def test_shows_search_results
          Search::Settings.current.update_attributes!(terms_facets: %w(Color Size))
          create_product(
            id: 'PRODUCT1',
            name: 'Pretty Nice Shirt',
            filters:  { 'Size' => %w[Small Medium Large], 'Color' => 'Blue' },
            variants: [{ sku: 'SKU', regular: 35.to_m }],
            images: [{ image: product_image_file, option: 'Blue' }]
          )

          create_product(
            id: 'PRODUCT2',
            name: 'Great Pants',
            filters:  { 'Size' => %w[Small Medium Large], 'Color' => 'Brown' },
            variants: [{ sku: 'SKU', regular: 50.to_m }],
            images: [{ image: product_image_file, option: 'Brown' }]
          )

          content = Content.for('search')
          content.blocks.create!(
            area: :results,
            type: :text,
            data: { text: 'global search test content' }
          )

          get storefront_api.search_path(q: 'large')
          result = JSON.parse(response.body)

          assert(result['query_string'].present?)
          assert(result.key?('message'))
          assert(result.key?('redirect'))

          content_blocks = result['content_blocks']
          assert_equal(1, content_blocks.count)

          assert_equal(2, result['total_results'])
          assert_equal(2, result['facets'].count)

          products = result['products']
          assert_equal(2, products.count)
          assert_includes(products.map { |r| r['id'] }, 'PRODUCT1')
          assert_includes(products.map { |r| r['id'] }, 'PRODUCT2')
        end

        def test_shows_no_search_results
          Search::Settings.current.update_attributes!(terms_facets: %w(Color Size))
          create_product(
            id: 'PRODUCT1',
            name: 'Pretty Nice Shirt',
            filters:  { 'Size' => %w[Small Medium Large], 'Color' => 'Blue' },
            variants: [{ sku: 'SKU', regular: 35.to_m }],
            images: [{ image: product_image_file, option: 'Blue' }]
          )

          content = Content.for('search')
          content.blocks.create!(
            area: :results,
            type: :text,
            data: { text: 'global search test content' }
          )
          content.blocks.create!(
            area: :no_results,
            type: :text,
            data: { text: 'no results test content' }
          )

          get storefront_api.search_path(q: 'grand')
          result = JSON.parse(response.body)

          assert(result['query_string'].present?)
          assert(result.key?('message'))
          assert(result.key?('redirect'))

          content_blocks = result['content_blocks']
          assert_equal(2, content_blocks.count)

          assert_equal(0, result['total_results'])
          assert_equal(0, result['facets'].count)

          products = result['products']
          assert_equal(0, products.count)
        end
      end
    end
  end
end
