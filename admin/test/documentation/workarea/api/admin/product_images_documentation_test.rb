require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class ProductImagesDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Product Images'

        def product
          @product ||= create_product
        end

        def base_64
          'data:image/jpeg;base64,GEGseg42g3g...'
        end

        def url
          'http://dreamatico.com/data_images/kitten/kitten-2.jpg'
        end

        def sample_attributes
          { image_url: base_64 }
        end

        def create_image
          product.images.create!(sample_attributes)
        end

        def test_and_document_index
          description 'Listing product images'
          route admin_api.product_images_path(':product_id')

          2.times { create_image }

          record_request do
            get admin_api.product_images_path(product.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_create_from_url
          description 'Creating a product image from URL'
          route admin_api.product_images_path(':product_id')

          record_request do
            VCR.use_cassette('product_image_from_url') do
              post admin_api.product_images_path(product.id),
                    params: { image: { image_url: url } },
                    as: :json
            end

            assert_equal(201, response.status)
          end
        end

        def test_and_document_create_from_base_64
          description 'Creating a product image from Base64'
          route admin_api.product_images_path(':product_id')

          record_request do
            post admin_api.product_images_path(product.id),
                  params: { image: sample_attributes },
                  as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a product image'
          route admin_api.product_image_path(':product_id', ':id')

          image = create_image

          record_request do
            patch admin_api.product_image_path(product.id, image.id),
                    params: { image: { name: 'foo' } },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a product image'
          route admin_api.product_image_path(':product_id', ':id')

          image = create_image

          record_request do
            delete admin_api.product_image_path(product.id, image.id)
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
