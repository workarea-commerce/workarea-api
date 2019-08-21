module Workarea
  module Api
    module Admin
      class ProductImagesController < Admin::ApplicationController
        before_action :find_product
        before_action :find_image, except: [:index, :create]

        swagger_path '/products/{id}/images' do
          operation :get do
            key :summary, 'All Product Images'
            key :description, 'Returns all images for a product'
            key :operationId, 'listProductImages'
            key :produces, ['application/json']

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'product ID'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Product images'
              schema do
                key :type, :object
                property :images do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Catalog::ProductImage'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Product Image'
            key :description, 'Creates a new product image'
            key :operationId, 'addProductImage'
            key :produces, ['application/json']

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'product ID'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Image to add'
              key :required, true
              schema do
                key :type, :object
                property :image do
                  key :'$ref', 'Workarea::Catalog::ProductImage'
                end
              end
            end

            response 201 do
              key :description, 'Product image created'
              schema do
                key :type, :object
                property :image do
                  key :'$ref', 'Workarea::Catalog::ProductImage'
                end
              end
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Catalog::ProductImage'
                end
              end
            end
          end
        end

        def index
          respond_with images: @product.images
        end

        def create
          @image = @product.images.create!(params[:image])
          respond_with(
            { image: @image },
            { status: :created,
            location: product_images_path(@product.id) }
          )
        end

        swagger_path '/products/{product_id}/images/{id}' do
          operation :patch do
            key :summary, 'Update a product image'
            key :description, 'Updates attributes on a product image'
            key :operationId, 'updateProductImage'

            parameter do
              key :name, :product_id
              key :in, :path
              key :description, 'ID of product'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of product image to update'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'New attributes'
              key :required, true
              schema do
                key :type, :object
                property :image do
                  key :'$ref', 'Workarea::Catalog::ProductImage'
                end
              end
            end

            response 204 do
              key :description, 'Product image updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Catalog::ProductImage'
                end
              end
            end

            response 404 do
              key :description, 'Product or image not found'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :params do
                  key :type, :object
                  key :additionalProperties, true
                end
              end
            end
          end

          operation :delete do
            key :summary, 'Remove a Product Image'
            key :description, 'Remove a product image'
            key :operationId, 'removeProductImage'

            parameter do
              key :name, :product_id
              key :in, :path
              key :description, 'ID of product'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of product image to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Product image removed successfully'
            end

            response 404 do
              key :description, 'Product or image not found'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :params do
                  key :type, :object
                  key :additionalProperties, true
                end
              end
            end
          end
        end

        def update
          @image.update_attributes!(params[:image])
          respond_with image: @image
        end

        def destroy
          @image.destroy
          head :no_content
        end

        private

        def find_product
          @product = Catalog::Product.find(params[:product_id])
        end

        def find_image
          @image = @product.images.find(params[:id])
        end
      end
    end
  end
end
