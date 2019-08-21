module Workarea
  module Api
    module Storefront
      class AnalyticsController < ActionController::Metal
        include ActionController::Head
        include ActionController::Instrumentation

        def category_view
          Metrics::CategoryByDay.inc(key: { category_id: params[:category_id] }, views: 1)
          head :ok
        end

        def product_view
          Metrics::ProductByDay.inc(key: { product_id: params[:product_id] }, views: 1)
          head :ok
        end

        def search
          Metrics::SearchByDay.save_search(params[:q], params[:total_results])
          head :ok
        end

        def search_abandonment
          warn <<~eos
DEPRECATION WARNING: Search abandonment tracking is deprecated and will be removed \
in Workarea 3.5.
          eos
          head :ok
        end

        def filters
          warn <<~eos
DEPRECATION WARNING: Filter analytics tracking is deprecated and will be removed \
in Workarea 3.5.
          eos
          head :ok
        end
      end
    end
  end
end
