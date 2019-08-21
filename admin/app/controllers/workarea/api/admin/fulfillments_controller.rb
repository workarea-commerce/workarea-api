module Workarea
  module Api
    module Admin
      class FulfillmentsController < Admin::ApplicationController
        before_action :find_fulfillment, except: [:index, :create, :bulk]

        swagger_path '/fulfillments' do
          operation :get do
            key :summary, 'All Fulfillments'
            key :description, 'Returns all fulfillments from the system'
            key :operationId, 'listFulfillments'
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
              key :description, 'Fulfillments'
              schema do
                key :type, :object
                property :categories do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Fulfillment'
                  end
                end
              end
            end
          end
        end

        def index
          @fulfillments = Fulfillment
                            .all
                            .by_updated_at(starts_at: params[:updated_at_starts_at], ends_at: params[:updated_at_ends_at])
                            .order_by(sort_field => sort_direction)
                            .page(params[:page])
          respond_with fulfillments: @fulfillments
        end

        swagger_path '/fulfillments/{id}' do
          operation :get do
            key :summary, 'Find Fulfillment by ID'
            key :description, 'Returns a single fulfillment'
            key :operationId, 'showFulfillment'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of fulfillment to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Fulfillment details'
              schema do
                key :'$ref', 'Workarea::Fulfillment'
              end
            end

            response 404 do
              key :description, 'Fulfillment not found'
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
          respond_with fulfillment: @fulfillment
        end

        swagger_path '/fulfillments/{id}/ship_items' do
          operation :post do
            key :summary, 'Mark Items as Shipped'
            key :description, 'Marks items in a fulfillment as shipped (sent to customer)'
            key :operationId, 'markItemsAsShipped'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of fulfillment'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :required, true
              schema do
                key :type, :object
                key :required, %i(tracking_number items)
                property :tracking_number do
                  key :type, :string
                  key :description, 'Tracking number being shipped'
                end
                property :items do
                  key :type, :array
                  items do
                    key :type, :object
                    property :id do
                      key :type, :string
                      key :description, 'The order item ID for the item being shipped'
                    end
                    property :quantity do
                      key :type, :integer
                    end
                  end
                end
              end
            end

            response 201 do
              key :description, 'Fulfillment details'
              schema do
                key :type, :object
                property :fulfillment do
                  key :'$ref', 'Workarea::Fulfillment'
                end
              end
            end

            response 404 do
              key :description, 'Fulfillment not found'
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

        def ship_items
          if @fulfillment.ship_items(params[:tracking_number], items)
            respond_with(
              { fulfillment: @fulfillment },
              { location: fulfillment_path(@fulfillment) }
            )
          else
            raise Mongoid::Errors::Validations.new(@fulfillment)
          end
        end

        swagger_path '/fulfillments/{id}/cancel_items' do
          operation :post do
            key :summary, 'Mark Items as Canceled'
            key :description, 'Marks items in a fulfillment as canceled (will not be sent to customer)'
            key :operationId, 'markItemsAsCanceled'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of fulfillment'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :required, true
              schema do
                key :type, :object
                key :required, %i(items)
                property :items do
                  key :type, :array
                  items do
                    key :type, :object
                    property :id do
                      key :type, :string
                      key :description, 'The order item ID for the item being canceled'
                    end
                    property :quantity do
                      key :type, :integer
                    end
                  end
                end
              end
            end

            response 201 do
              key :description, 'Fulfillment details'
              schema do
                key :type, :object
                property :fulfillment do
                  key :'$ref', 'Workarea::Fulfillment'
                end
              end
            end

            response 404 do
              key :description, 'Fulfillment not found'
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

        def cancel_items
          if @fulfillment.cancel_items(items)
            respond_with(
              { fulfillment: @fulfillment },
              { location: fulfillment_path(@fulfillment) }
            )
          else
            raise Mongoid::Errors::Validations.new(@fulfillment)
          end
        end

        private

        def find_fulfillment
          @fulfillment = Fulfillment.find(params[:id])
        end

        def items
          Array(params[:items]).map(&:to_h)
        end
      end
    end
  end
end
