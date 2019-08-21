require 'test_helper'

module Workarea
  module Api
    module Admin
      class CategoryProductRulesIntegrationTest < IntegrationTest
        include Workarea::Admin::IntegrationTest

        setup :set_sample_attributes

        def set_sample_attributes
          @category = create_category
          @sample_attributes = { name: 'search', operator: 'equals', value: '*' }
        end

        def create_rule
          @category.product_rules.create!(@sample_attributes)
        end

        def test_lists_rules
          rules = [create_rule, create_rule]
          get admin_api.category_product_rules_path(@category.id)
          result = JSON.parse(response.body)['product_rules']

          assert_equal(2, result.length)
          assert_equal(rules.first, ProductRule.new(result.first))
          assert_equal(rules.second, ProductRule.new(result.second))
        end

        def test_creates_rules
          data = @sample_attributes

          assert_difference '@category.reload; @category.product_rules.count;', 1 do
            post admin_api.category_product_rules_path(@category.id),
              params: { product_rule: data }
          end
        end

        def test_updates_rules
          rule = create_rule
          patch admin_api.category_product_rule_path(@category.id, rule.id),
            params: { product_rule: { value: 'foo' } }

          rule.reload
          assert_equal('foo', rule.value)
        end

        def test_destroys_rules
          rule = create_rule

          assert_difference '@category.reload; @category.product_rules.count;', -1 do
            delete admin_api.category_product_rule_path(@category.id, rule.id)
          end
        end
      end
    end
  end
end
