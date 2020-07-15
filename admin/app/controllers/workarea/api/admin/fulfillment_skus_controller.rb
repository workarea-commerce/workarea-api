module Workarea
  module Api
    module Admin
      class FulfillmentSkusController < Admin::ApplicationController
        before_action :find_fulfillment_sku, except: [:index, :create, :bulk]

        swagger_path '/fulfillment_skus' do
          operation :get do
            key :summary, 'All Fulfillment SKUs'
            key :description, 'Returns all fulfillment SKUs from the system'
            key :operationId, 'listFulfillmentSkus'
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
              key :description, 'Fulfillment SKUs'
              schema do
                key :type, :object
                property :fulfillment_skus do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Fulfillment::Sku'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Fulfillment SKU'
            key :description, 'Creates a new fulfillment SKU.'
            key :operationId, 'addFulfillmentSku'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Fulfillment SKU to add'
              key :required, true
              schema do
                key :type, :object
                property :fulfillment_sku do
                  key :'$ref', 'Workarea::Fulfillment::Sku'
                end
              end
            end

            response 201 do
              key :description, 'Fulfillment SKU created'
              schema do
                key :type, :object
                property :fulfillment_sku do
                  key :'$ref', 'Workarea::Fulfillment::Sku'
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
                  key :'$ref', 'Workarea::Fulfillment::Sku'
                end
              end
            end
          end
        end

        def index
          @fulfillment_skus = Fulfillment::Sku
                            .all
                            .by_updated_at(starts_at: params[:updated_at_starts_at], ends_at: params[:updated_at_ends_at])
                            .by_created_at(starts_at: params[:created_at_starts_at], ends_at: params[:created_at_ends_at])
                            .order_by(sort_field => sort_direction)
                            .page(params[:page])

          respond_with fulfillment_skus: @fulfillment_skus
        end

        def create
          @fulfillment_sku = Fulfillment::Sku.create!(params[:fulfillment_sku])
          respond_with(
            { fulfillment_sku: @fulfillment_sku },
            { status: :created,
            location: fulfillment_sku_path(@fulfillment_sku) }
          )
        end

        swagger_path '/fulfillment_skus/{id}' do
          operation :get do
            key :summary, 'Find Fulfillment SKU by ID'
            key :description, 'Returns a single fulfillment SKU'
            key :operationId, 'showFulfillmentSku'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of fulfillment SKU to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Fulfillment SKU details'
              schema do
                key :type, :object
                property :fulfillment_sku do
                  key :'$ref', 'Workarea::Fulfillment::Sku'
                end
              end
            end

            response 404 do
              key :description, 'Fulfillment SKU not found'
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
            key :summary, 'Update an Fulfillment SKU'
            key :description, 'Updates attributes on an fulfillment SKU'
            key :operationId, 'updateFulfillmentSku'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of fulfillment SKU to update'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :required, true
              schema do
                key :type, :object
                property :fulfillment_sku do
                  key :description, 'New attributes'
                  key :'$ref', 'Workarea::Fulfillment::Sku'
                end
              end
            end

            response 204 do
              key :description, 'Fulfillment SKU updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Fulfillment::Sku'
                end
              end
            end

            response 404 do
              key :description, 'Fulfillment SKU not found'
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
            key :summary, 'Remove an Fulfillment SKU'
            key :description, 'Remove an Fulfillment SKU'
            key :operationId, 'removeFulfillmentSku'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of fulfillment SKU to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Fulfillment SKU removed successfully'
            end

            response 404 do
              key :description, 'Fulfillment SKU not found'
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
          respond_with fulfillment_sku: @fulfillment_sku
        end

        def update
          @fulfillment_sku.update_attributes!(params[:fulfillment_sku])
          respond_with fulfillment_sku: @fulfillment_sku
        end

        swagger_path '/fulfillment_skus/bulk' do
          operation :patch do
            key :summary, 'Bulk Upsert Fulfillment SKUs'
            key :description, 'Creates new fulfillment SKUs or updates existing ones in bulk.'
            key :operationId, 'upsertFulfillmentSkus'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Array of fulfillment SKUs to upsert'
              key :required, true
              schema do
                key :type, :object
                property :fulfillment_skus do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Fulfillment::Sku'
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
            klass: Fulfillment::Sku,
            data: params[:fulfillment_skus].map(&:to_h)
          )

          head :no_content
        end

        def destroy
          @fulfillment_sku.destroy
          head :no_content
        end

        private

        def find_fulfillment_sku
          @fulfillment_sku = Fulfillment::Sku.find(params[:id])
        end
      end
    end
  end
end
