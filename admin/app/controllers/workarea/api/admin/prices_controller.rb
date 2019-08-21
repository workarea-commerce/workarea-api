module Workarea
  module Api
    module Admin
      class PricesController < Admin::ApplicationController
        before_action :find_sku
        before_action :find_price, except: [:index, :create]

        swagger_path '/pricing_skus/{id}/prices' do
          operation :get do
            key :summary, 'All Pricing SKU Prices'
            key :description, 'Returns all prices for a pricing SKU'
            key :operationId, 'listPricingSkuPrices'
            key :produces, ['application/json']

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'Pricing SKU ID'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Pricing SKU prices'
              schema do
                key :type, :object
                property :prices do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Pricing::Price'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Pricing SKU Price'
            key :description, 'Creates a new pricing SKU price.'
            key :operationId, 'addPricingSkuPrice'
            key :produces, ['application/json']

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'Pricing SKU ID'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Price to add'
              key :required, true
              schema do
                key :type, :object
                property :price do
                  key :'$ref', 'Workarea::Pricing::Price'
                end
              end
            end

            response 201 do
              key :description, 'Price created'
              schema do
                key :type, :object
                property :price do
                  key :'$ref', 'Workarea::Pricing::Price'
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
                  key :'$ref', 'Workarea::Pricing::Price'
                end
              end
            end
          end
        end

        def index
          respond_with prices: @sku.prices
        end

        def create
          @price = @sku.prices.create!(params[:price])
          respond_with(
            { price: @price },
            { status: :created,
            location: pricing_sku_prices_path(@sku) }
          )
        end

        swagger_path '/pricing_skus/{pricing_sku_id}/price/{id}' do
          operation :patch do
            key :summary, 'Update a Pricing SKU Price'
            key :description, 'Updates attributes on a pricing SKU price'
            key :operationId, 'updatePricingSkuPrice'

            parameter do
              key :name, :pricing_sku_id
              key :in, :path
              key :description, 'ID of pricing SKU'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of price to update'
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
                property :price do
                  key :'$ref', 'Workarea::Pricing::Price'
                end
              end
            end

            response 204 do
              key :description, 'Pricing SKU price updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Pricing::Price'
                end
              end
            end

            response 404 do
              key :description, 'Pricing SKU or price not found'
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
            key :summary, 'Remove a Pricing SKU Price'
            key :description, 'Remove a price'
            key :operationId, 'removePricingSkuPrice'

            parameter do
              key :name, :pricing_sku_id
              key :in, :path
              key :description, 'ID of pricing SKU'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of pricing SKU price to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Price removed successfully'
            end

            response 404 do
              key :description, 'Pricing SKU or price not found'
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
          @price.update_attributes!(params[:price])
          respond_with price: @price
        end

        def destroy
          @price.destroy
          head :no_content
        end

        private

        def find_sku
          @sku = Pricing::Sku.find(params[:pricing_sku_id])
        end

        def find_price
          @price = @sku.prices.find(params[:id])
        end
      end
    end
  end
end
