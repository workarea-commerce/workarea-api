module Workarea
  module Api
    module Admin
      class ProductsController < Admin::ApplicationController
        before_action :find_product, except: [:index, :create, :bulk]

        swagger_path '/products' do
          operation :get do
            key :summary, 'All Products'
            key :description, 'Returns all products from the system'
            key :operationId, 'listProducts'
            key :produces, ['application/json']

            parameter do
              key :name, :page
              key :in, :query
              key :description, 'Current page'
              key :required, false
              key :type, :integer
              key :default, 1
            end
            parameter do
              key :name, :sort_by
              key :in, :query
              key :description, 'Field on which to sort (see responses for possible values)'
              key :required, false
              key :type, :string
              key :default, 'created_at'
            end
            parameter do
              key :name, :sort_direction
              key :in, :query
              key :description, 'Direction for sort by'
              key :type, :string
              key :enum, %w(asc desc)
              key :default, 'desc'
            end

            response 200 do
              key :description, 'Products'
              schema do
                key :type, :object
                property :products do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Catalog::Product'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Product'
            key :description, 'Creates a new product.'
            key :operationId, 'addProduct'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Product to add'
              key :required, true
              schema do
                key :type, :object
                property :product do
                  key :'$ref', 'Workarea::Catalog::Product'
                end
              end
            end

            response 201 do
              key :description, 'Product created'
              schema do
                key :type, :object
                property :product do
                  key :'$ref', 'Workarea::Catalog::Product'
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
                  key :'$ref', 'Workarea::Catalog::Product'
                end
              end
            end
          end
        end

        def index
          @products = Catalog::Product
                        .all
                        .order_by(sort_field => sort_direction)
                        .page(params[:page])

          respond_with products: @products
        end

        def create
          @product = Catalog::Product.create!(params[:product])
          respond_with(
            { product: @product },
            { status: :created,
            location: product_path(@product.id) }
          )
        end

        swagger_path '/products/{id}' do
          operation :get do
            key :summary, 'Find Product by ID'
            key :description, 'Returns a single product'
            key :operationId, 'showProduct'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of product to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Product details'
              schema do
                key :type, :object
                property :product do
                  key :'$ref', 'Workarea::Catalog::Product'
                end
              end
            end

            response 404 do
              key :description, 'Product not found'
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

          operation :patch do
            key :summary, 'Update a Product'
            key :description, 'Updates attributes on a product'
            key :operationId, 'updateProduct'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of product to update'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :required, true
              schema do
                key :type, :object
                property :product do
                  key :description, 'New attributes'
                  key :'$ref', 'Workarea::Catalog::Product'
                end
              end
            end

            response 204 do
              key :description, 'Product updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Catalog::Product'
                end
              end
            end

            response 404 do
              key :description, 'Product not found'
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
            key :summary, 'Remove a Product'
            key :description, 'Remove a product'
            key :operationId, 'removeProduct'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of product to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Product removed successfully'
            end

            response 404 do
              key :description, 'Product not found'
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

        def show
          respond_with product: @product
        end

        def update
          @product.update_attributes!(params[:product])
          respond_with product: @product
        end

        swagger_path '/products/bulk' do
          operation :patch do
            key :summary, 'Bulk Upsert Products'
            key :description, 'Creates new products or updates existing ones in bulk.'
            key :operationId, 'upsertProducts'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Array of products to upsert'
              key :required, true
              schema do
                key :type, :object
                property :products do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Catalog::Product'
                  end
                end
              end
            end

            response 204 do
              key :description, 'Upsert received'
            end
          end
        end

        def bulk
          @bulk = Api::Admin::BulkUpsert.create!(
            klass: Catalog::Product,
            data: params[:products].map(&:to_h)
          )

          head :no_content
        end

        def destroy
          @product.destroy
          head :no_content
        end

        private

        def find_product
          @product = Catalog::Product.find(params[:id])
        end
      end
    end
  end
end
