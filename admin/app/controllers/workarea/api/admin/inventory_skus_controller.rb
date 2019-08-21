module Workarea
  module Api
    module Admin
      class InventorySkusController < Admin::ApplicationController
        before_action :find_inventory_sku, except: [:index, :create, :bulk]

        swagger_path '/inventory_skus' do
          operation :get do
            key :summary, 'All Inventory SKUs'
            key :description, 'Returns all inventory SKUs from the system'
            key :operationId, 'listInventorySkus'
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
              key :description, 'Inventory SKUs'
              schema do
                key :type, :object
                property :inventory_skus do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Inventory::Sku'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Inventory SKU'
            key :description, 'Creates a new inventory SKU.'
            key :operationId, 'addInventorySku'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Inventory SKU to add'
              key :required, true
              schema do
                key :type, :object
                property :inventory_sku do
                  key :'$ref', 'Workarea::Inventory::Sku'
                end
              end
            end

            response 201 do
              key :description, 'Inventory SKU created'
              schema do
                key :type, :object
                property :inventory_sku do
                  key :'$ref', 'Workarea::Inventory::Sku'
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
                  key :'$ref', 'Workarea::Inventory::Sku'
                end
              end
            end
          end
        end

        def index
          @inventory_skus = Inventory::Sku
                              .all
                              .by_updated_at(starts_at: params[:updated_at_starts_at], ends_at: params[:updated_at_ends_at])
                              .by_created_at(starts_at: params[:created_at_starts_at], ends_at: params[:created_at_ends_at])
                              .order_by(sort_field => sort_direction)
                              .page(params[:page])

          respond_with inventory_skus: @inventory_skus
        end

        def create
          @inventory_sku = Inventory::Sku.create!(params[:inventory_sku])
          respond_with(
            { inventory_sku: @inventory_sku },
            { status: :created,
            location: inventory_sku_path(@inventory_sku) }
          )
        end

        swagger_path '/inventory_skus/{id}' do
          operation :get do
            key :summary, 'Find Inventory SKU by ID'
            key :description, 'Returns a single inventory SKU'
            key :operationId, 'showInventorySku'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of inventory SKU to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Inventory SKU details'
              schema do
                key :type, :object
                property :inventory_sku do
                  key :'$ref', 'Workarea::Inventory::Sku'
                end
              end
            end

            response 404 do
              key :description, 'Inventory SKU not found'
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
            key :summary, 'Update an Inventory SKU'
            key :description, 'Updates attributes on an inventory SKU'
            key :operationId, 'updateInventorySku'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of inventory SKU to update'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :required, true
              schema do
                key :type, :object
                property :inventory_sku do
                  key :description, 'New attributes'
                  key :'$ref', 'Workarea::Inventory::Sku'
                end
              end
            end

            response 204 do
              key :description, 'Inventory SKU updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Inventory::Sku'
                end
              end
            end

            response 404 do
              key :description, 'Inventory SKU not found'
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
            key :summary, 'Remove an Inventory SKU'
            key :description, 'Remove an Inventory SKU'
            key :operationId, 'removeInventorySku'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of inventory SKU to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Inventory SKU removed successfully'
            end

            response 404 do
              key :description, 'Inventory SKU not found'
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
          respond_with inventory_sku: @inventory_sku
        end

        def update
          @inventory_sku.update_attributes!(params[:inventory_sku])
          respond_with inventory_sku: @inventory_sku
        end

        swagger_path '/inventory_skus/bulk' do
          operation :patch do
            key :summary, 'Bulk Upsert Inventory SKUs'
            key :description, 'Creates new inventory SKUs or updates existing ones in bulk.'
            key :operationId, 'upsertInventorySkus'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Array of inventory SKUs to upsert'
              key :required, true
              schema do
                key :type, :object
                property :inventory_skus do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Inventory::Sku'
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
            klass: Inventory::Sku,
            data: params[:inventory_skus].map(&:to_h)
          )

          head :no_content
        end

        def destroy
          @inventory_sku.destroy
          head :no_content
        end

        private

        def find_inventory_sku
          @inventory_sku = Inventory::Sku.find(params[:id])
        end
      end
    end
  end
end
