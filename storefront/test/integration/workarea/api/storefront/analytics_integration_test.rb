require 'test_helper'

module Workarea
  module Api
    module Storefront
      class AnalyticsIntegrationTest < Workarea::IntegrationTest
        def test_saving_category_view
          post storefront_api.analytics_category_view_path(category_id: 'foo')
          assert_equal(1, Metrics::CategoryByDay.first.views)
        end

        def test_saving_product_view
          post storefront_api.analytics_product_view_path(product_id: 'foo')
          assert_equal(1, Metrics::ProductByDay.first.views)
        end

        def test_saving_search
          post storefront_api.analytics_search_path,
            params: { q: 'foo', total_results: 5 }

          insights = Metrics::SearchByDay.first
          assert_equal(1, insights.searches)
          assert_equal(5, insights.total_results)
        end

        def test_saving_search_abandonment
          # Saving abandonment is deprecated, and this will be removed in v3.5
        end

        def test_saving_filters
          # Saving filters is deprecated, and this will be removed in v3.5
        end
      end
    end
  end
end
