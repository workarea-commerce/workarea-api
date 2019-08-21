require 'test_helper'

module Workarea
  module Api
    module Storefront
      class SearchesIntegrationTest < IntegrationTest
        def test_showing_search_autocomplete
          create_product(name: 'Foo')
          create_category(name: 'Foo Category')
          create_page(name: 'Foo Page')

          Metrics::SearchByDay.save_search('foo', 3)
          travel_to 1.weeks.from_now
          GenerateInsights.generate_all!
          BulkIndexSearches.perform

          get storefront_api.searches_path(q: 'foo')
          results = JSON.parse(response.body)['results']
          assert_equal(4, results.length)

          search = results.detect { |r| r['type'] == 'Searches' }
          assert(search.present?)
          assert_equal('foo', search['value'])
          assert_equal(storefront_api.search_path(q: 'foo'), search['url'])

          product = results.detect { |r| r['type'] == 'Products' }
          assert(product.present?)
          assert_equal('Foo', product['value'])
          assert_match(/product_images/, product['image'])
          assert_equal(storefront_api.product_path('foo'), product['url'])

          category = results.detect { |r| r['type'] == 'Categories' }
          assert(category.present?)
          assert_equal('Foo Category', category['value'])
          assert_equal(storefront_api.category_path('foo-category'), category['url'])

          page = results.detect { |r| r['type'] == 'Pages' }
          assert(page.present?)
          assert_equal('Foo Page', page['value'])
          assert_equal(storefront_api.page_path('foo-page'), page['url'])
        end

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
