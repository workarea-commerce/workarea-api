require 'test_helper'

module Workarea
  module Api
    module Admin
      class PaymentsIntegrationTest < IntegrationTest
        include Workarea::Api::IntegrationTesting
        include Workarea::Admin::IntegrationTest

        def test_lists_payments
          payments = [create_payment, create_payment]
          get admin_api.payments_path
          result = JSON.parse(response.body)['payments']

          assert_equal(2, result.length)
          assert_equal(payments.second, Payment.new(result.first))
          assert_equal(payments.first, Payment.new(result.second))

          travel_to 1.week.from_now

          get admin_api.payments_path(
            updated_at_starts_at: 5.days.ago,
            updated_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['payments']

          assert_equal(0, result.length)

          get admin_api.payments_path(
            created_at_starts_at: 5.days.ago,
            created_at_ends_at: 4.days.ago
          )
          result = JSON.parse(response.body)['payments']

          assert_equal(0, result.length)

          get admin_api.payments_path(
            updated_at_starts_at: 8.days.ago,
            updated_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['payments']
          assert_equal(2, result.length)

          get admin_api.payments_path(
            created_at_starts_at: 8.days.ago,
            created_at_ends_at: 6.days.ago
          )
          result = JSON.parse(response.body)['payments']
          assert_equal(2, result.length)
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
