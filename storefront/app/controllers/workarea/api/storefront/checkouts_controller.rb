module Workarea
  module Api
    module Storefront
      class CheckoutsController < Api::Storefront::ApplicationController
        include CurrentCheckout

        class InvalidCheckout < RuntimeError; end

        before_action :set_checkout_view_models
        before_action :start_checkout, only: [:show, :update]
        before_action :validate_checkout, only: :show
        before_action :check_inventory, only: [:show, :complete]
        before_action :remove_unpurchasable_items, only: [:show, :complete]
        before_action :check_lock, only: :complete
        around_action :with_order_lock, only: [:update, :complete]
        before_action :touch_checkout, only: [:update, :complete]
        before_action { params.permit! }

        rescue_from InvalidCheckout, with: :handle_checkout_error

        def show
          render_checkout
        end

        def update
          success = current_checkout.update(params)
          render_checkout(status: success ? :ok : :unprocessable_entity)
        end

        def complete
          payment = Workarea::Checkout::Steps::Payment.new(current_checkout)
          payment.update(params)

          if payment.complete? && current_checkout.place_order
            Workarea::Storefront::OrderMailer
              .confirmation(current_order.id)
              .deliver_later

            @order = Workarea::Storefront::OrderViewModel.new(current_order)
            render template: 'workarea/api/storefront/orders/show'
          else
            flash[:error] =
              t('workarea.storefront.flash_messages.order_place_error')
            render_checkout status: :unprocessable_entity
          end
        end

        def reset
          current_checkout.reset!
          start_checkout
          render_checkout
        end

        private

        def render_checkout(status: :ok)
          Pricing.perform(current_order, current_checkout.shipping)
          render template: 'workarea/api/storefront/checkouts/show',
                 status: status
        end

        def start_checkout
          return if current_order.checking_out?

          if authentication?
            current_checkout.start_as(current_user)
          else
            current_checkout.start_as(:guest)
          end
        end

        def validate_checkout
          message =
            if !current_order || current_order.no_items?
              t('workarea.storefront.flash_messages.items_required')
            elsif current_order.started_checkout? && !current_order.checking_out?
              t('workarea.storefront.flash_messages.checkout_expired')
            end

          raise InvalidCheckout.new(message) if message
        end

        def with_order_lock
          current_order.lock!
          yield
          current_order.unlock! if current_order
        end

        def check_lock
          raise InvalidCheckout.new(
            t('workarea.storefront.flash_messages.checkout_lock_error')
          ) if current_order.locked?
        end

        def touch_checkout
          if authentication?
            current_order.touch_checkout!(
              ip_address: request.remote_ip,
              user_activity_id: current_user.id,
              checkout_by_id: current_user.id,
              source: 'storefront_api'
            )
          else
            current_order.touch_checkout!(
              ip_address: request.remote_ip,
              source: 'storefront_api'
            )
          end
        end

        def handle_checkout_error(e)
          render json: { problem: e.message }, status: :unprocessable_entity
        end
      end
    end
  end
end
