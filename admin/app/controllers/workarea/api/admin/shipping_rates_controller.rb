module Workarea
  module Api
    module Admin
      class ShippingRatesController < Admin::ApplicationController
        before_action :find_shipping_service
        before_action :find_rate, except: [:index, :create]

        swagger_path '/shipping_services/{id}/rates' do
          operation :get do
            key :summary, 'All Shipping Service Rates'
            key :description, 'Returns all rates for a shipping service'
            key :operationId, 'listShippingServiceRates'
            key :produces, ['application/json']

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'shipping service ID'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Shipping service rates'
              schema do
                key :type, :object
                property :rates do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Shipping::Rate'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create Shipping Service Rate'
            key :description, 'Creates a new shipping service rate.'
            key :operationId, 'addShippingServiceRate'
            key :produces, ['application/json']

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'shipping service ID'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Rate to add'
              key :required, true
              schema do
                key :type, :object
                property :rate do
                  key :'$ref', 'Workarea::Shipping::Rate'
                end
              end
            end

            response 201 do
              key :description, 'Tax rate created'
              schema do
                key :type, :object
                property :rate do
                  key :'$ref', 'Workarea::Shipping::Rate'
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
                  key :'$ref', 'Workarea::Shipping::Rate'
                end
              end
            end
          end
        end

        def index
          respond_with rates: @shipping_service.rates
        end

        def create
          @rate = @shipping_service.rates.create!(params[:rate])
          respond_with(
            { rate: @rate },
            { status: :created,
            location: shipping_service_rates_path(@shipping_service) }
          )
        end

        swagger_path '/shipping_services/{shipping_service_id}/rates/{id}' do
          operation :patch do
            key :summary, 'Update a shipping service rate'
            key :description, 'Updates attributes on a shipping service rate'
            key :operationId, 'updateShippingServiceRate'

            parameter do
              key :name, :shipping_service_id
              key :in, :path
              key :description, 'ID of shipping service to update'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of shipping service rate to update'
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
                property :rate do
                  key :'$ref', 'Workarea::Shipping::Rate'
                end
              end
            end

            response 204 do
              key :description, 'Shipping service rate updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::Shipping::Rate'
                end
              end
            end

            response 404 do
              key :description, 'Shipping service or rate not found'
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
            key :summary, 'Remove a Shipping Service Rate'
            key :description, 'Remove a shipping service rate'
            key :operationId, 'removeShippingServiceRate'

            parameter do
              key :name, :shipping_service_id
              key :in, :path
              key :description, 'ID of shipping service'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of rate to update'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'Shipping service rate removed successfully'
            end

            response 404 do
              key :description, 'Shipping service or rate not found'
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
          @rate.update_attributes!(params[:rate])
          respond_with rate: @rate
        end

        def destroy
          @rate.destroy
          head :no_content
        end

        private

        def find_shipping_service
          @shipping_service = Shipping::Service.find(params[:shipping_service_id])
        end

        def find_rate
          @rate = @shipping_service.rates.find(params[:id])
        end
      end
    end
  end
end
