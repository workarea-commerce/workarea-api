module Workarea
  module Api
    module Storefront
      class AnalyticsController < Api::Storefront::ApplicationController
        def category_view
          Metrics::CategoryByDay.inc(key: { category_id: params[:category_id] }, views: 1)

          if current_metrics_id.present?
            Metrics::User.save_affinity(
              id: current_metrics_id,
              action: 'viewed',
              category_ids: params[:category_id]
            )
          end

          head :ok
        end

        def product_view
          Metrics::ProductByDay.inc(key: { product_id: params[:product_id] }, views: 1)

          if current_metrics_id.present?
            Metrics::User.save_affinity(
              id: current_metrics_id,
              action: 'viewed',
              product_ids: params[:product_id]
            )
          end

          head :ok
        end

        def search
          query_string = QueryString.new(params[:q])

          if query_string.present? && !query_string.short?
            Metrics::SearchByDay.save_search(params[:q], params[:total_results])

            if current_metrics_id.present?
              Metrics::User.save_affinity(
                id: current_metrics_id,
                action: 'viewed',
                search_ids: query_string.id
              )
            end
          end

          head :ok
        end
      end
    end
  end
end
