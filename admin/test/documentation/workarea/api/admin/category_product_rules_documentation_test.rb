require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Admin
      class CategoryProductRulesDocumentationTest < DocumentationTest
        include Workarea::Admin::IntegrationTest

        resource 'Category Product Rules'

        def category
          @category ||= create_category
        end

        def sample_attributes
          { name: 'search', operator: 'equals', value: '*' }
        end

        def create_rule
          category.product_rules.create!(sample_attributes)
        end

        def test_and_document_index
          description 'Listing category product rules'
          route admin_api.category_product_rules_path(':category_id')

          2.times { create_rule }

          record_request do
            get admin_api.category_product_rules_path(category.id)
            assert_equal(200, response.status)
          end
        end

        def test_and_document_create
          description 'Creating a category product rule'
          route admin_api.category_product_rules_path(':category_id')

          record_request do
            post admin_api.category_product_rules_path(category.id),
              params: { product_rule: sample_attributes },
              as: :json

            assert_equal(201, response.status)
          end
        end

        def test_and_document_update
          description 'Updating a category product rule'
          route admin_api.category_product_rule_path(':category_id', ':id')

          rule = create_rule

          record_request do
            patch admin_api.category_product_rule_path(category.id, rule.id),
                    params: { product_rule: { value: 'foo' } },
                    as: :json

            assert_equal(204, response.status)
          end
        end

        def test_and_document_destroy
          description 'Removing a category product rule'
          route admin_api.category_product_rule_path(':category_id', ':id')

          rule = create_rule

          record_request do
            delete admin_api.category_product_rule_path(category.id, rule.id)
            assert_equal(204, response.status)
          end
        end
      end
    end
  end
end
