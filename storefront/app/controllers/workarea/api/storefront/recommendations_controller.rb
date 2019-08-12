module Workarea
  module Api
    module Storefront
      class RecommendationsController < Api::Storefront::ApplicationController
        before_action :assert_current_metrics_id

        def show
          fresh_when(
            etag: user_activity,
            last_modified: user_activity.updated_at,
            public: true
          )

          @recommendations = Workarea::Storefront::PersonalizedRecommendationsViewModel.new(
            user_activity,
            view_model_options
          )
        end
      end
    end
  end
end
