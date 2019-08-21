require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class CategoriesDocumentationTest < DocumentationTest
        resource 'Categories'

        setup :set_product
        setup :set_category
        setup :set_taxonomy
        setup :set_content

        def set_product
          @product = create_product(
            name: 'Sweet Shirt',
            filters:  { size: %w[Small Medium Large], color: 'Blue' },
            variants: [{ sku: 'SKU', details: { color: 'Blue' }, regular: 2.to_m }],
            details: { size: 'Small', color: 'Red' },
            images: [{ image: product_image_file, option: 'Blue' }]
          )
        end

        def set_category
          @category = create_category(
            name: 'Shirts',
            product_ids: [@product.id],
            terms_facets: %w(Size Color)
          )
        end

        def set_taxonomy
          first_level = create_taxon(name: 'Mens')
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

        def test_and_document_index
          description 'Showing a listing of categories'
          route storefront_api.categories_path
          parameter 'page', 'Page number'
          explanation <<-EOS
            This endpoint will give you a paginated list of all active
            categories, that is, all categories that could be shown on the
            storefront.
          EOS

          create_category(name: 'Pants')

          record_request do
            get storefront_api.categories_path(page: '1')
            assert_equal(200, response.status)
          end
        end

        def test_and_document_show
          description 'Showing a category'
          route storefront_api.category_path(':slug')
          parameter 'sort', 'Sort by'
          parameter 'page', 'Page number'
          parameter ':facet_name', 'Each facet setup on the category will have a corresponding parameter'
          explanation <<-EOS
            This endpoint includes everything you need to render a category,
            including any associated content, products, and filters.
          EOS

          record_request do
            get storefront_api.category_path(@category, page: '1', sort: 'price_desc')
            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
