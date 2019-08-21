require 'test_helper'

module Workarea
  module Api
    module Admin
      class PaymentTransactionsIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        def create_transaction
          payment = create_payment
          payment.set_credit_card(
            number: '1',
            month: 1,
            year: Time.now.year + 1,
            cvv: '999'
          )

          Payment::Transaction.create!(
            payment: payment,
            tender_id: payment.credit_card.id,
            amount: 45,
            action: 'authorize'
          )
        end

        def test_lists_transactions
          transactions = [create_transaction, create_transaction]
          get admin_api.payment_transactions_path
          result = JSON.parse(response.body)['transactions']

          assert_equal(2, result.length)
          assert_equal(transactions.second, Payment::Transaction.new(result.first))
          assert_equal(transactions.first, Payment::Transaction.new(result.second))
        end

        def test_shows_transactions
          transaction = create_transaction
          get admin_api.payment_transaction_path(transaction.id)
          result = JSON.parse(response.body)['transaction']
          assert_equal(transaction, Payment::Transaction.new(result))
        end
      end
    end
  end
end
