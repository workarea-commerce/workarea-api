module Workarea
  module Api
    module Storefront
      class RecentViewsController < Api::Storefront::ApplicationController
        before_action :assert_current_metrics_id

        def show
          @recent_views = Workarea::Storefront::UserActivityViewModel.new(
            current_metrics
          )
        end

        def update
          product_ids = Array.wrap(params[:product_id])
          category_ids = Array.wrap(params[:category_id])
          search_ids = Array.wrap(params[:search])

          if current_metrics_id.present?
            Metrics::User.save_affinity(
              id: current_metrics_id,
              action: 'viewed',
              product_ids: product_ids,
              category_ids: category_ids,
              search_ids: search_ids
            )
          end

          head :ok
        end
      end
    end
  end
end
