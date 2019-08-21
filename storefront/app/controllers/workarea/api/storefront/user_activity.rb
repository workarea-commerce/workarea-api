module Workarea
  module Api
    module Storefront
      module UserActivity
        extend ActiveSupport::Concern

        def user_activity
          @user_activity ||= Recommendation::UserActivity.find_or_initialize_by(
            id: current_user_activity_id
          )
        end

        def current_user_activity_id
          if authentication?
            current_user.id
          else
            params[:session_id]
          end
        end

        def assert_current_user_activity_id
          if current_user_activity_id.blank?
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
