module Workarea
  module Api
    module Storefront
      class RecentViewsController < Api::Storefront::ApplicationController
        before_action :assert_current_metrics_id

        def show
          if stale?(
            etag: user_activity,
            last_modified: user_activity.updated_at,
            public: true
          )
            @recent_views = Workarea::Storefront::UserActivityViewModel.new(
              user_activity
            )
          end
        end

        def update
          product_ids = Array.wrap(params[:product_id])
          category_ids = Array.wrap(params[:category_id])
          search_ids = Array.wrap(params[:search])

          Metrics::User.save_affinity(
            id: current_metrics_id,
            action: 'viewed',
            product_ids: product_ids,
            category_ids: category_ids,
            search_ids: search_ids
          )

          head :ok
        end
      end
    end
  end
end
