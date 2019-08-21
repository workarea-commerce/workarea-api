module Workarea
  module Api
    module Admin
      class VariantsController < Admin::ApplicationController
        before_action :find_product
        before_action :find_variant, except: [:index, :create]

        swagger_path '/products/{id}/variants' do
          operation :get do
            key :summary, 'All Product Variants'
            key :description, 'Returns all variants for a product'
            key :operationId, 'listProductVariants'
            key :produces, ['application/json']

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'product ID'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Product variants'
              schema do
                key :type, :object
                property :variants do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Catalog::Variant'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Product Variant'
            key :description, 'Creates a new produt variant'
            key :operationId, 'addProductVariant'
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
              key :description, 'Variant to add'
              key :required, true
              schema do
                key :type, :object
                property :variant do
                  key :'$ref', 'Workarea::Catalog::Variant'
                end
              end
            end

            response 201 do
              key :description, 'Variant created'
              schema do
                key :type, :object
                property :variant do
                  key :'$ref', 'Workarea::Catalog::Variant'
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
                  key :'$ref', 'Workarea::Catalog::Variant'
                end
              end
            end
          end
        end

        def index
          respond_with variants: @product.variants
        end

        def create
          @variant = @product.variants.create!(params[:variant])
          respond_with(
            { variant: @variant },
            { status: :created,
            location: product_variants_path(@product) }
          )
        end

        swagger_path '/products/{product_id}/variants/{id}' do
          operation :patch do
            key :summary, 'Update a product variant'
            key :description, 'Updates attributes on a product variant'
            key :operationId, 'updateProductVariant'

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
              key :description, 'ID of variant to update'
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
                property :variant do
                  key :'$ref', 'Workarea::Catalog::Variant'
                end
              end
            end

            response 204 do
              key :description, 'Variant updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Catalog::Variant'
                end
              end
            end

            response 404 do
              key :description, 'Product or variant not found'
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
            key :summary, 'Remove a Product Variant'
            key :description, 'Remove a product variant'
            key :operationId, 'removeProductVariant'

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
              key :description, 'ID of variant to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Variant removed successfully'
            end

            response 404 do
              key :description, 'Product or variant not found'
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
          @variant.update_attributes!(params[:variant])
          respond_with variant: @variant
        end

        def destroy
          @variant.destroy
          head :no_content
        end

        private

        def find_product
          @product = Catalog::Product.find(params[:product_id])
        end

        def find_variant
          @variant = @product.variants.find(params[:id])
        end
      end
    end
  end
end
