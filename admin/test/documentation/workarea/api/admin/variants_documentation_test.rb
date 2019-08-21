require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class VariantsDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Variants'

        def product
          @product ||= create_product
        end

        def sample_attributes
          product.variants.first.as_json.except('_id')
        end

        def create_variant
          product.variants.create!(
            sample_attributes.merge('sku' => "SKU#{rand(1000)}").except('name')
          )
        end

        def test_and_document_index
          description 'Listing product variants'
          route admin_api.product_variants_path(':product_id')

          2.times { create_variant }

          record_request do
            get admin_api.product_variants_path(product.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a product variant'
          route admin_api.product_variants_path(':product_id')

          record_request do
            post admin_api.product_variants_path(product.id),
                  params: { variant: sample_attributes },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a product variant'
          route admin_api.product_variant_path(':product_id', ':id')

          variant = create_variant

          record_request do
            patch admin_api.product_variant_path(product.id, variant.id),
                    params: { variant: { name: 'Foo' } },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a product variant'
          route admin_api.product_variant_path(':product_id', ':id')

          variant = create_variant

          record_request do
            delete admin_api.product_variant_path(product.id, variant.id)
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
