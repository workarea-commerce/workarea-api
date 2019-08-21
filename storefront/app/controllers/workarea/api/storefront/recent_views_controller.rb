module Workarea
  module Api
    module Storefront
      class RecentViewsController < Api::Storefront::ApplicationController
        before_action :assert_current_user_activity_id

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
          if params[:product_id].present?
            Recommendation::UserActivity.save_product(
              current_user_activity_id,
              params[:product_id]
            )
          end

          if params[:category_id].present?
            Recommendation::UserActivity.save_category(
              current_user_activity_id,
              params[:category_id]
            )
          end

          if params[:search].present?
            Recommendation::UserActivity.save_search(
              current_user_activity_id,
              params[:search]
            )
          end

          head :ok
        end
      end
    end
  end
end
