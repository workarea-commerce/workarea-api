require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class SearchesDocumentationTest < DocumentationTest
        resource 'Searches'

        setup :set_content

        def set_content
          @content = Content.for('search')
          @content.blocks.create!(
            area: :results,
            type: :text,
            data: { text: 'Huzzah! Your search results are below!' }
          )
          @content.blocks.create!(
            area: :no_results,
            type: :text,
            data: { text: 'Sorry, we can\'t find what you searched for!' }
          )
        end

        def test_and_document_autocomplete
          description 'Showing search autocomplete suggestions'
          route storefront_api.searches_path
          explanation <<-EOS
            This list will be based on popular search terms and matching
            products, categories, etc. Useful for showing a autocomplete
            drop-down as a customer types in a search bar.
          EOS

          create_product(name: 'Red Product')
          create_category(name: 'Red Category')
          create_page(name: 'Page about Red Products')

          Metrics::SearchByDay.save_search('red', 3)
          travel_to 1.weeks.from_now
          GenerateInsights.generate_all!
          BulkIndexSearches.perform
          travel_back

          record_request do
            get storefront_api.searches_path(q: 'red')
            assert_equal(200, response.status)
          end
        end

        def test_and_document_show
          description 'Showing search results'
          route storefront_api.search_path
          parameter 'q', 'The search query string entered by the customer'
          parameter 'sort', 'Sort by'
          parameter 'page', 'Page number'
          parameter ':facet_name', 'Each facet setup on search settings will have a corresponding parameter'
          explanation <<-EOS
            This endpoint returns everything you'll need to show search results
            to customers. This includes products, filters, and any content
            that's been setup by an administrator.
          EOS

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

          record_request do
            get storefront_api.search_path(q: 'large', page: '1', sort: 'price_desc')
            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
