require 'test_helper'

module Workarea
  module Api
    module Admin
      class PaymentsIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        def test_lists_payments
          payments = [create_payment, create_payment]
          get admin_api.payments_path
          result = JSON.parse(response.body)['payments']

          assert_equal(2, result.length)
          assert_equal(payments.second, Payment.new(result.first))
          assert_equal(payments.first, Payment.new(result.second))
        end

        def test_shows_payments
          payment = create_payment
          get admin_api.payment_path(payment.id)
          result = JSON.parse(response.body)
          assert_equal(payment, Payment.new(result['payment']))
          assert_includes(result.keys, 'payment_transactions')
        end
      end
    end
  end
end
