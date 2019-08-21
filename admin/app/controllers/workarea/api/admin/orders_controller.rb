module Workarea
  module Api
    module Admin
      class OrdersController < Admin::ApplicationController
        swagger_path '/orders' do
          operation :get do
            key :summary, 'All Ordsers'
            key :description, 'Returns all orders from the system'
            key :operationId, 'listOrders'
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
            parameter do
              key :name, :placed_at_greater_than
              key :in, :query
              key :description, 'Starting date-time for getting orders by when they were placed'
              key :type, :string
              key :format, 'date-time'
            end
            parameter do
              key :name, :placed_at_less_than
              key :in, :query
              key :description, 'Ending date-time for getting orders by when they were placed'
              key :type, :string
              key :format, 'date-time'
            end
            parameter do
              key :name, :email
              key :in, :query
              key :description, 'Email address associated to the orders'
              key :required, false
              key :type, :integer
            end

            parameter :updated_at_starts_at
            parameter :updated_at_ends_at
            parameter :created_at_starts_at
            parameter :created_at_ends_at

            response 200 do
              key :description, 'Orders'
              schema do
                key :type, :object
                property :orders do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Order'
                  end
                end
              end
            end
          end
        end

        def index
          criteria = Order.all

          if params[:email].present?
            criteria = criteria.where(email: params[:email])
          end

          if params[:placed_at_greater_than].present?
            # TODO Workarea v4, rename to placed_at_starts_at
            criteria = criteria.where(:placed_at.gte => params[:placed_at_greater_than])
          end

          if params[:placed_at_less_than].present?
            # TODO Workarea v4, rename to placed_at_ends_at
            criteria = criteria.where(:placed_at.lte => params[:placed_at_less_than])
          end

          @orders =
            criteria
            .by_updated_at(starts_at: params[:updated_at_starts_at], ends_at: params[:updated_at_ends_at])
            .by_created_at(starts_at: params[:created_at_starts_at], ends_at: params[:created_at_ends_at])
            .order_by(sort_field => sort_direction)
            .page(params[:page].presence || 1)

          respond_with orders: @orders
        end

        swagger_path '/orders/{id}' do
          operation :get do
            key :summary, 'Find Order by ID'
            key :description, 'Returns a single order'
            key :operationId, 'showOrder'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of order to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Order details'
              schema do
                key :type, :object
                property :order do
                  key :'$ref', 'Workarea::Order'
                end
                property :payment do
                  key :'$ref', 'Workarea::Payment'
                end
                property :payment_transactions do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Payment::Transaction'
                  end
                end
                property :fulfillment do
                  key :'$ref', 'Workarea::Fulfillment'
                end
                property :shippings do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Shipping'
                  end
                end
              end
            end

            response 404 do
              key :description, 'Order not found'
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
          @order = Order.find(params[:id])
          @payment = Payment.find_or_initialize_by(id: @order.id)
          @fulfillment = Fulfillment.find_or_initialize_by(id: @order.id)
          @shippings = Shipping.where(order_id: @order.id).to_a

          respond_with order: @order,
                       payment: @payment,
                       payment_transactions: @payment.transactions,
                       fulfillment: @fulfillment,
                       shippings: @shippings
        end
      end
    end
  end
end
