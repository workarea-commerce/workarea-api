module Workarea
  module Api
    module Admin
      class ShippingSkusController < Admin::ApplicationController
        before_action :find_shipping_sku, except: [:index, :create, :bulk]

        swagger_path '/shipping_skus' do
          operation :get do
            key :summary, 'All Shipping SKUs'
            key :description, 'Returns all shipping SKUs from the system'
            key :operationId, 'listShippingSkus'
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

            parameter :updated_at_starts_at
            parameter :updated_at_ends_at
            parameter :created_at_starts_at
            parameter :created_at_ends_at

            response 200 do
              key :description, 'Shipping SKUs'
              schema do
                key :type, :object
                property :shipping_skus do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Shipping::Sku'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Shipping SKU'
            key :description, 'Creates a new shipping SKU.'
            key :operationId, 'addShippingSku'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Shipping SKU to add'
              key :required, true
              schema do
                key :type, :object
                property :shipping_sku do
                  key :'$ref', 'Workarea::Shipping::Sku'
                end
              end
            end

            response 201 do
              key :description, 'Shipping SKU created'
              schema do
                key :type, :object
                property :shipping_sku do
                  key :'$ref', 'Workarea::Shipping::Sku'
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
                  key :'$ref', 'Workarea::Shipping::Sku'
                end
              end
            end
          end
        end

        def index
          @shipping_skus = Shipping::Sku
                            .all
                            .by_updated_at(starts_at: params[:updated_at_starts_at], ends_at: params[:updated_at_ends_at])
                            .by_created_at(starts_at: params[:created_at_starts_at], ends_at: params[:created_at_ends_at])
                            .order_by(sort_field => sort_direction)
                            .page(params[:page])

          respond_with shipping_skus: @shipping_skus
        end

        def create
          @shipping_sku = Shipping::Sku.create!(params[:shipping_sku])
          respond_with(
            { shipping_sku: @shipping_sku },
            { status: :created,
            location: shipping_sku_path(@shipping_sku) }
          )
        end

        swagger_path '/shipping_skus/{id}' do
          operation :get do
            key :summary, 'Find Shipping SKU by ID'
            key :description, 'Returns a single shipping SKU'
            key :operationId, 'showShippingSku'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of shipping SKU to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Shipping SKU details'
              schema do
                key :type, :object
                property :shipping_sku do
                  key :'$ref', 'Workarea::Shipping::Sku'
                end
              end
            end

            response 404 do
              key :description, 'Shipping SKU not found'
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
            key :summary, 'Update an Shipping SKU'
            key :description, 'Updates attributes on an shipping SKU'
            key :operationId, 'updateShippingSku'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of shipping SKU to update'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :required, true
              schema do
                key :type, :object
                property :shipping_sku do
                  key :description, 'New attributes'
                  key :'$ref', 'Workarea::Shipping::Sku'
                end
              end
            end

            response 204 do
              key :description, 'Shipping SKU updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Shipping::Sku'
                end
              end
            end

            response 404 do
              key :description, 'Shipping SKU not found'
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
            key :summary, 'Remove an Shipping SKU'
            key :description, 'Remove an Shipping SKU'
            key :operationId, 'removeShippingSku'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of shipping SKU to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Shipping SKU removed successfully'
            end

            response 404 do
              key :description, 'Shipping SKU not found'
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
          respond_with shipping_sku: @shipping_sku
        end

        def update
          @shipping_sku.update_attributes!(params[:shipping_sku])
          respond_with shipping_sku: @shipping_sku
        end

        swagger_path '/shipping_skus/bulk' do
          operation :patch do
            key :summary, 'Bulk Upsert Shipping SKUs'
            key :description, 'Creates new shipping SKUs or updates existing ones in bulk.'
            key :operationId, 'upsertShippingSkus'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Array of shipping SKUs to upsert'
              key :required, true
              schema do
                key :type, :object
                property :shipping_skus do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Shipping::Sku'
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
            klass: Shipping::Sku,
            data: params[:shipping_skus].map(&:to_h)
          )

          head :no_content
        end

        def destroy
          @shipping_sku.destroy
          head :no_content
        end

        private

        def find_shipping_sku
          @shipping_sku = Shipping::Sku.find(params[:id])
        end
      end
    end
  end
end
