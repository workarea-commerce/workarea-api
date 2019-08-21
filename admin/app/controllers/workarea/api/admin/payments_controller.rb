module Workarea
  module Api
    module Admin
      class PaymentsController < Admin::ApplicationController
        swagger_path '/payments' do
          operation :get do
            key :summary, 'All Payments'
            key :description, 'Returns all payments from the system'
            key :operationId, 'listPayments'
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
              key :description, 'Payments'
              schema do
                key :type, :object
                property :payments do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Payment'
                  end
                end
              end
            end
          end
        end

        def index
          @payments = Payment
                        .all
                        .order_by(sort_field => sort_direction)
                        .page(params[:page])

          respond_with payments: @payments
        end

        swagger_path '/payments/{id}' do
          operation :get do
            key :summary, 'Find Payment by ID'
            key :description, 'Returns a single payment'
            key :operationId, 'showPayment'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of payment to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Payment details'
              schema do
                key :type, :object
                property :payment do
                  key :'$ref', 'Workarea::Payment'
                end
                property :payment_transactions do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Payment::Transaction'
                  end
                end
              end
            end

            response 404 do
              key :description, 'Payment not found'
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
          @payment = Payment.find(params[:id])
          respond_with payment: @payment,
                       payment_transactions: @payment.transactions
        end
      end
    end
  end
end
