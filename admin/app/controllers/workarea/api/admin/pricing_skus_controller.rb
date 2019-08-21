module Workarea
  module Api
    module Admin
      class PricingSkusController < Admin::ApplicationController
        before_action :find_pricing_sku, except: [:index, :create, :bulk]

        swagger_path '/pricing_skus' do
          operation :get do
            key :summary, 'All Pricing SKUs'
            key :description, 'Returns all pricing SKUs from the system'
            key :operationId, 'listPricingSkus'
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
              key :description, 'Pricing SKUs'
              schema do
                key :type, :object
                property :pricing_skus do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Pricing::Sku'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Pricing SKU'
            key :description, 'Creates a new pricing SKU.'
            key :operationId, 'addPricingSku'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Pricing SKU to add'
              key :required, true
              schema do
                key :type, :object
                property :pricing_sku do
                  key :'$ref', 'Workarea::Pricing::Sku'
                end
              end
            end

            response 201 do
              key :description, 'Pricing SKU created'
              schema do
                key :type, :object
                property :pricing_sku do
                  key :'$ref', 'Workarea::Pricing::Sku'
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
                  key :'$ref', 'Workarea::Pricing::Sku'
                end
              end
            end
          end
        end

        def index
          @pricing_skus = Pricing::Sku
                            .all
                            .by_updated_at(starts_at: params[:updated_at_starts_at], ends_at: params[:updated_at_ends_at])
                            .by_created_at(starts_at: params[:created_at_starts_at], ends_at: params[:created_at_ends_at])
                            .order_by(sort_field => sort_direction)
                            .page(params[:page])

          respond_with pricing_skus: @pricing_skus
        end

        def create
          @pricing_sku = Pricing::Sku.create!(params[:pricing_sku])
          respond_with(
            { pricing_sku: @pricing_sku },
            { status: :created,
            location: pricing_sku_path(@pricing_sku) }
          )
        end

        swagger_path '/pricing_skus/{id}' do
          operation :get do
            key :summary, 'Find Pricing SKU by ID'
            key :description, 'Returns a single pricing SKU'
            key :operationId, 'showPricingSku'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of pricing SKU to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Pricing SKU details'
              schema do
                key :type, :object
                property :pricing_sku do
                  key :'$ref', 'Workarea::Pricing::Sku'
                end
              end
            end

            response 404 do
              key :description, 'Pricing SKU not found'
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
            key :summary, 'Update an Pricing SKU'
            key :description, 'Updates attributes on an pricing SKU'
            key :operationId, 'updatePricingSku'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of pricing SKU to update'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :required, true
              schema do
                key :type, :object
                property :pricing_sku do
                  key :description, 'New attributes'
                  key :'$ref', 'Workarea::Pricing::Sku'
                end
              end
            end

            response 204 do
              key :description, 'Pricing SKU updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Pricing::Sku'
                end
              end
            end

            response 404 do
              key :description, 'Pricing SKU not found'
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
            key :summary, 'Remove an Pricing SKU'
            key :description, 'Remove an Pricing SKU'
            key :operationId, 'removePricingSku'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of pricing SKU to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Pricing SKU removed successfully'
            end

            response 404 do
              key :description, 'Pricing SKU not found'
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
          respond_with pricing_sku: @pricing_sku
        end

        def update
          @pricing_sku.update_attributes!(params[:pricing_sku])
          respond_with pricing_sku: @pricing_sku
        end

        swagger_path '/pricing_skus/bulk' do
          operation :patch do
            key :summary, 'Bulk Upsert Pricing SKUs'
            key :description, 'Creates new pricing SKUs or updates existing ones in bulk.'
            key :operationId, 'upsertPricingSkus'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Array of pricing SKUs to upsert'
              key :required, true
              schema do
                key :type, :object
                property :pricing_skus do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Pricing::Sku'
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
            klass: Pricing::Sku,
            data: params[:pricing_skus].map(&:to_h)
          )

          head :no_content
        end

        def destroy
          @pricing_sku.destroy
          head :no_content
        end

        private

        def find_pricing_sku
          @pricing_sku = Pricing::Sku.find(params[:id])
        end
      end
    end
  end
end
