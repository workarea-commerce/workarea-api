module Workarea
  module Api
    module Storefront
      class OrdersController < Api::Storefront::ApplicationController
        def index
          models = Order.recent(
            current_user.id,
            Workarea.config.storefront_user_order_display_count
          )
          statuses = Fulfillment.find_statuses(*models.map(&:id))

          @orders = models.map do |order|
            Workarea::Storefront::OrderViewModel.new(
              order,
              fulfillment_status: statuses[order.id]
            )
          end
        end

        def show
          model = Order.find(params[:id])

          if model.user_id != current_user.id.to_s
            head :forbidden
          else
            @order = Workarea::Storefront::OrderViewModel.new(model)
          end
        end
      end
    end
  end
end
