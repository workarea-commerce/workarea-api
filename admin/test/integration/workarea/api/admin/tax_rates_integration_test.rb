require 'test_helper'

module Workarea
  module Api
    module Admin
      class TaxRatesIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @tax_category = create_tax_category(rates: [])
          @sample_attributes = { percentage: 0.06, country: 'US', region: 'PA' }
        end

        def create_tax_rate
          @tax_category.rates.create!(@sample_attributes)
        end

        def test_lists_tax_rates
          2.times { create_tax_rate }
          get admin_api.tax_category_rates_path(@tax_category)
          result = JSON.parse(response.body)['rates']
          assert_equal(2, result.length)
        end

        def test_creates_tax_rates
          assert_difference 'Tax::Rate.count', 1 do
            post admin_api.tax_category_rates_path(@tax_category),
              params: { rate: @sample_attributes }
          end
        end

        def test_shows_tax_rates
          tax_rate = create_tax_rate
          get admin_api.tax_category_rate_path(@tax_category, tax_rate)
          result = JSON.parse(response.body)['rate']
          assert_equal(tax_rate, Tax::Rate.new(result))
        end

        def test_updates_tax_rates
          tax_rate = create_tax_rate
          patch admin_api.tax_category_rate_path(@tax_category, tax_rate),
            params: { rate: { percentage: 0.08 } }

          assert_equal(0.08, tax_rate.reload.percentage)
        end

        def test_bulk_upserts_tax_rates
          assert_difference 'Tax::Rate.count', 10 do
            patch admin_api.bulk_tax_category_rates_path(@tax_category),
              params: { rates: [@sample_attributes] * 10 }
          end
        end

        def test_destroys_tax_rates
          tax_rate = create_tax_rate

          assert_difference 'Tax::Rate.count', -1 do
            delete admin_api.tax_category_rate_path(@tax_category, tax_rate)
          end
        end
      end
    end
  end
end
