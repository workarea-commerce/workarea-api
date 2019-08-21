module Workarea
  module Api
    module Admin
      class ShippingServicesController < Admin::ApplicationController
        before_action :find_shipping_service, except: [:index, :create, :bulk]

        swagger_path '/shipping_services' do
          operation :get do
            key :summary, 'All Shipping Services'
            key :description, 'Returns all shipping services from the system'
            key :operationId, 'listShippingServices'
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
              key :description, 'Shipping services'
              schema do
                key :type, :object
                property :shipping_services do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Shipping::Service'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Shipping Service'
            key :description, 'Creates a new shipping service.'
            key :operationId, 'addShippingService'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Shipping service to add'
              key :required, true
              schema do
                key :type, :object
                property :shipping_service do
                  key :'$ref', 'Workarea::Shipping::Service'
                end
              end
            end

            response 201 do
              key :description, 'Shipping service created'
              schema do
                key :type, :object
                property :shipping_service do
                  key :'$ref', 'Workarea::Shipping::Service'
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
                  key :'$ref', 'Workarea::Shipping::Service'
                end
              end
            end
          end
        end

        def index
          @shipping_services = Shipping::Service
                                .all
                                .by_updated_at(starts_at: params[:updated_at_starts_at], ends_at: params[:updated_at_ends_at])
                                .by_created_at(starts_at: params[:created_at_starts_at], ends_at: params[:created_at_ends_at])
                                .order_by(sort_field => sort_direction)
                                .page(params[:page])

          respond_with shipping_services: @shipping_services
        end

        def create
          @shipping_service = Shipping::Service.create!(params[:shipping_service])
          respond_with(
            { shipping_service: @shipping_service },
            { status: :created,
            location: shipping_service_path(@shipping_service) }
          )
        end

        swagger_path '/shipping_services/{id}' do
          operation :get do
            key :summary, 'Find Shipping Service by ID'
            key :description, 'Returns a single shipping service'
            key :operationId, 'showShippingService'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of shipping service to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Shipping service details'
              schema do
                key :'$ref', 'Workarea::Shipping::Service'
              end
            end

            response 404 do
              key :description, 'Shipping service not found'
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
            key :summary, 'Update a Shipping Service'
            key :description, 'Updates attributes on a shipping service'
            key :operationId, 'updateShippingService'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of shipping service to update'
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
                property :shipping_service do
                  key :'$ref', 'Workarea::Shipping::Service'
                end
              end
            end

            response 204 do
              key :description, 'Shipping service updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Shipping::Service'
                end
              end
            end

            response 404 do
              key :description, 'Shipping service not found'
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
            key :summary, 'Remove a Shipping Service'
            key :description, 'Remove a shipping service'
            key :operationId, 'removeShippingService'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of shipping service to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Shipping service removed successfully'
            end

            response 404 do
              key :description, 'Shipping service not found'
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
          respond_with shipping_service: @shipping_service
        end

        def update
          @shipping_service.update_attributes!(params[:shipping_service])
          respond_with shipping_service: @shipping_service
        end

        swagger_path '/shipping_services/bulk' do
          operation :patch do
            key :summary, 'Bulk Upsert Shipping Services'
            key :description, 'Creates new shipping services or updates existing ones in bulk.'
            key :operationId, 'upsertShippingServices'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Array of shipping services to upsert'
              key :required, true
              schema do
                key :type, :array
                items do
                  key :'$ref', 'Workarea::Shipping::Service'
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
            klass: Shipping::Service,
            data: params[:shipping_services].map(&:to_h)
          )

          head :no_content
        end

        def destroy
          @shipping_service.destroy
          head :no_content
        end

        private

        def find_shipping_service
          @shipping_service = Shipping::Service.find(params[:id])
        end
      end
    end
  end
end
