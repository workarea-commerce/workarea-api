module Workarea
  module Api
    module Admin
      class PaymentTransactionsController < Admin::ApplicationController
        swagger_path '/payment_transactions' do
          operation :get do
            key :summary, 'All Payment Transactions'
            key :description, 'Returns all payment transactions from the system'
            key :operationId, 'listPaymentTransactions'
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
              key :description, 'Payment transactions'
              schema do
                key :type, :object
                property :transactions do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Payment::Transaction'
                  end
                end
              end
            end
          end
        end

        def index
          @transactions = Payment::Transaction
                            .all
                            .order_by(sort_field => sort_direction)
                            .page(params[:page])

          respond_with transactions: @transactions
        end

        swagger_path '/payment_transactions/{id}' do
          operation :get do
            key :summary, 'Find Payment Transaction by ID'
            key :description, 'Returns a single payment transaction'
            key :operationId, 'showPaymentTransaction'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of payment transaction to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Payment transaction details'
              schema do
                key :type, :object
                property :transaction do
                  key :'$ref', 'Workarea::Payment::Transaction'
                end
              end
            end

            response 404 do
              key :description, 'Payment transaction not found'
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
          @transaction = Payment::Transaction.find(params[:id])
          respond_with transaction: @transaction
        end
      end
    end
  end
end
