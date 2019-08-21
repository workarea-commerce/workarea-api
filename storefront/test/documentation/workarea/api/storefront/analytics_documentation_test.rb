require 'test_helper'
require 'workarea/api/documentation_test'

module Workarea
  module Api
    module Storefront
      class AnalyticsDocumentationTest < DocumentationTest
        resource 'Analytics'

        def test_and_document_saving_a_category_view
          description 'saving a category view'
          route storefront_api.analytics_category_view_path(category_id: ':category_id')
          explanation 'saving a category view will be reflected in admin reports'

          record_request do
            post storefront_api.analytics_category_view_path(category_id: '12345')
            assert_equal(200, response.status)
          end
        end

        def test_and_document_saving_a_product_view
          description 'saving a product view'
          route storefront_api.analytics_product_view_path(product_id: ':product_id')
          explanation 'saving a product view will be reflected in admin reports'

          record_request do
            post storefront_api.analytics_product_view_path(product_id: '12345')
            assert_equal(200, response.status)
          end
        end

        def test_and_document_saving_a_search
          description 'Saving a search'
          route storefront_api.analytics_search_path
          explanation <<-EOS
            Saving a search will be reflected in admin reports. This is intended
            to be called once per search performed by a customer.
          EOS

          record_request do
            post storefront_api.analytics_search_path,
                  as: :json,
                  params: { q: 'foo', total_results: 5 }

            assert_equal(200, response.status)
          end
        end
      end
    end
  end
end
