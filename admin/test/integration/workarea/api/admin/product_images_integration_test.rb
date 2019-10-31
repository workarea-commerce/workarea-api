require 'test_helper'

module Workarea
  module Api
    module Admin
      class ProductImagesIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @product = create_product
          @sample_attributes = { image: product_image_file }
        end

        def create_image
          @product.images.create!(@sample_attributes)
        end

        def test_lists_images
          images = [create_image, create_image]
          get admin_api.product_images_path(@product.id)
          result = JSON.parse(response.body)['images']

          assert_equal(2, result.length)
          assert_equal(images.first, Catalog::ProductImage.new(result.first))
          assert_equal(images.second, Catalog::ProductImage.new(result.second))
        end

        def test_creates_images
          data = @sample_attributes

          assert_difference '@product.reload.images.count', 1 do
            post admin_api.product_images_path(@product.id), params: { image: data }
          end
        end

        def test_updates_images
          image = create_image
          patch admin_api.product_image_path(@product.id, image.id),
            params: { image: { name: 'foo' } }

          assert_equal('foo', image.reload.name)
        end

        def test_destroys_images
          image = create_image

          assert_difference '@product.reload.images.count', -1 do
            delete admin_api.product_image_path(@product.id, image.id)
          end
        end
      end
    end
  end
end
