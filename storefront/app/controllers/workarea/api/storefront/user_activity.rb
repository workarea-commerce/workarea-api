module Workarea
  module Api
    module Storefront
      module UserActivity
        extend ActiveSupport::Concern

        def user_activity
          @user_activity ||= Metrics::User.find_or_initialize_by(
            id: current_metrics_id
          )
        end

        def current_metrics_id
          if authentication?
            current_user.email
          else
            params[:session_id]
          end
        end

        def assert_current_metrics_id
          if current_metrics_id.blank?
            render(
              json: {
                problem: t('workarea.api.storefront.recent_views.missing_id')
              },
              status: :unprocessable_entity
            )

            return false
          end
        end
      end
    end
  end
end
