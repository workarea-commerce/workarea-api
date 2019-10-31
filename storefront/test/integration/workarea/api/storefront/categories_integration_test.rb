require 'test_helper'

module Workarea
  module Api
    module Storefront
      class CategoriesIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTesting
        setup :set_product
        setup :set_category
        setup :set_taxonomy
        setup :set_content

        def set_product
          @product = create_product(
            filters:  { size: %w[Small Medium Large], color: 'Blue' },
            variants: [{ sku: 'SKU', details: { color: 'Blue' }, regular: 2.to_m }],
            details: { size: 'Small', color: 'Red' },
            images: [{ image: product_image_file, option: 'Blue' }]
          )
        end

        def set_category
          @category = create_category(
            product_ids: [@product.id],
            terms_facets: %w(Size Color)
          )
        end

        def set_taxonomy
          first_level = create_taxon(name: 'First Level')
          @taxon = first_level.children.create!(navigable: @category)
        end

        def set_content
          content = Content.for(@category)
          content.blocks.build(
            area: :above_results,
            type: :text,
            data: { text: 'text' }
          )
          content.blocks.build(
            area: :below_results,
            type: :text,
            data: { text: 'text' }
          )
          content.save!
        end

        def test_shows_categories_index
          create_category

          get storefront_api.categories_path
          result = JSON.parse(response.body)

          assert_equal(2, result['categories'].size)
        end

        def test_shows_categories
          get storefront_api.category_path(@category.slug)
          result = JSON.parse(response.body)

          assert_equal(@category.id.to_s, result['id'])

          assert_equal(3, result['breadcrumbs'].count)
          assert_equal(@taxon.id.to_s, result['breadcrumbs'].last['id'])

          assert_equal(2, result['content_blocks'].count)

          assert_equal(1, result['total_results'])

          assert_equal(1, result['facets'].count)

          product_result = result['products'].first
          assert_equal(1, result['products'].count)
          assert_equal(@product.id, product_result['id'])

          processors = product_result['images'].first['urls'].map { |p| p['type'].to_sym }
          processors.each do |processor|
            refute_includes(Workarea.config.api_product_image_jobs_blacklist, processor)
          end
        end
      end
    end
  end
end
