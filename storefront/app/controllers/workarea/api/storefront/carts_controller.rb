module Workarea
  module Api
    module Storefront
      class CartsController < Api::Storefront::ApplicationController
        include CurrentCheckout

        before_action :set_checkout_view_models, except: [:index, :create]
        before_action :remove_unpurchasable_items, except: [:index, :create]
        before_action :check_inventory, except: [:index, :create]

        def index
          @orders = Workarea::Storefront::OrderViewModel.wrap(
            Order.carts.where(user_id: current_user.id).to_a
          )
        end

        def create
          order = Order.new
          order.user_id = current_user.id if authentication?
          order.save!

          @order = Workarea::Storefront::OrderViewModel.new(
            order,
            view_model_options
          )

          render :show
        end

        def show
          Pricing.perform(current_order, current_checkout.shipping)
        end

        def add_promo_code
          if Pricing.valid_promo_code?(params[:promo_code], current_checkout.email)
            current_order.add_promo_code(params[:promo_code])
          else
            flash[:error] = t('workarea.storefront.flash_messages.promo_code_error')
          end

          Pricing.perform(current_order, current_checkout.shipping)
          render :show
        end
      end
    end
  end
end
