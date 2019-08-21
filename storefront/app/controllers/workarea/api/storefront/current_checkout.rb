module Workarea
  module Api
    module Storefront
      module CurrentCheckout
        def current_order
          return @current_order if defined?(@current_order)

          options = { id: params[:cart_id].presence || params[:id] }
          options[:user_id] = current_user.id if authentication?
          order = Order.carts.find_by(options)

          if order.user_id.present? && current_user.id.to_s != order.user_id
            raise Authentication::InvalidError
          end

          @current_order = order
        end

        def current_checkout
          @current_checkout ||=
            if authentication?
              Workarea::Checkout.new(current_order, current_user)
            else
              Workarea::Checkout.new(current_order)
            end
        end

        private

        def set_checkout_view_models
          @cart = Workarea::Storefront::CartViewModel.new(
            current_order,
            view_model_options
          )

          @summary = Workarea::Storefront::Checkout::SummaryViewModel.new(
            current_checkout,
            view_model_options
          )

          @order = Workarea::Storefront::OrderViewModel.new(
            current_order,
            view_model_options
          )
        end

        def remove_unpurchasable_items
          cleaner = CartCleaner.new(current_order)
          cleaner.clean
          flash[:info] = cleaner.messages if cleaner.message?
        end

        def check_inventory
          reservation = InventoryAdjustment.new(current_order).tap(&:perform)
          flash[:error] = reservation.errors if reservation.errors.present?
        end
      end
    end
  end
end
