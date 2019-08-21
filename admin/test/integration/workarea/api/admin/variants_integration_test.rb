require 'test_helper'

module Workarea
  module Api
    module Admin
      class VariantsIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @product = create_product
          @sample_attributes = @product.variants.first.as_json.except('_id')
        end

        def create_variant
          @product.variants.create!(@sample_attributes)
        end

        def test_lists_variants
          variants = [create_variant, create_variant]
          get admin_api.product_variants_path(@product.id)
          result = JSON.parse(response.body)['variants']

          assert_equal(3, result.length) # one pre-existing variant

          attrs = result.detect { |attr| attr['_id'] == variants.first.id.to_s }
          assert_equal(variants.first, Catalog::Variant.new(attrs))

          attrs = result.detect { |attr| attr['_id'] == variants.second.id.to_s }
          assert_equal(variants.second, Catalog::Variant.new(attrs))
        end

        def test_creates_variants
          data = @sample_attributes
          assert_difference '@product.reload.variants.count', 1 do
            post admin_api.product_variants_path(@product.id), params: { variant: data }
          end
        end

        def test_updates_variants
          variant = create_variant
          patch admin_api.product_variant_path(@product.id, variant.id),
            params: { variant: { name: 'foo' } }

          assert_equal('foo', variant.reload.name)
        end

        def test_destroys_variants
          variant = create_variant

          assert_difference '@product.reload.variants.count', -1 do
            delete admin_api.product_variant_path(@product.id, variant.id)
          end
        end
      end
    end
  end
end
