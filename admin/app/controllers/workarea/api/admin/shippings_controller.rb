module Workarea
  module Api
    module Admin
      class ShippingsController < Admin::ApplicationController
        swagger_path '/shippings' do
          operation :get do
            key :summary, 'All Shippings'
            key :description, 'Returns all shippings from the system'
            key :operationId, 'listShippings'
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
              key :description, 'Shippings'
              schema do
                key :type, :object
                property :shippings do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Shipping'
                  end
                end
              end
            end
          end
        end

        def index
          @shippings = Shipping
                          .all
                          .order_by(sort_field => sort_direction)
                          .page(params[:page])

          respond_with shippings: @shippings
        end

        swagger_path '/shippings/{id}' do
          operation :get do
            key :summary, 'Find Shipping Service by ID'
            key :description, 'Returns a single shipping'
            key :operationId, 'showShipping'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of shipping to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Shipping details'
              schema do
                key :'$ref', 'Workarea::Shipping'
              end
            end

            response 404 do
              key :description, 'Shipping not found'
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
          @shipping = Shipping.find(params[:id])
          respond_with shipping: @shipping
        end
      end
    end
  end
end
