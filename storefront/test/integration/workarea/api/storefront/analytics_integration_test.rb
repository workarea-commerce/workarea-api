require 'test_helper'

module Workarea
  module Api
    module Storefront
      class AnalyticsIntegrationTest < Workarea::IntegrationTest
        def test_saving_category_view
          post storefront_api.analytics_category_view_path(category_id: 'foo')
          assert_equal(1, Metrics::CategoryByDay.first.views)

          post storefront_api.analytics_category_view_path(category_id: 'foo', session_id: '1')
          assert_equal(2, Metrics::CategoryByDay.first.views)
          assert_equal(%w(foo), Metrics::User.find('1').viewed.category_ids)
        end

        def test_saving_product_view
          post storefront_api.analytics_product_view_path(product_id: 'foo')
          assert_equal(1, Metrics::ProductByDay.first.views)

          post storefront_api.analytics_product_view_path(product_id: 'foo', session_id: '1')
          assert_equal(2, Metrics::ProductByDay.first.views)
          assert_equal(%w(foo), Metrics::User.find('1').viewed.product_ids)
        end

        def test_saving_search
          post storefront_api.analytics_search_path,
            params: { q: 'foo', total_results: 5 }

          insights = Metrics::SearchByDay.first
          assert_equal(1, insights.searches)
          assert_equal(5, insights.total_results)

          post storefront_api.analytics_search_path,
            params: { q: 'foo', total_results: 5, session_id: '1' }
          assert_equal(2, insights.reload.searches)
          assert_equal(%w(foo), Metrics::User.find('1').viewed.search_ids)
        end
      end
    end
  end
end
