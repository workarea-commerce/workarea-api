module Workarea
  module Api
    module Storefront
      class CartItemsController < Api::Storefront::ApplicationController
        include CurrentCheckout

        before_action :set_checkout_view_models
        before_action :validate_customizations, only: [:create, :update]

        def create
          current_order.add_item(item_params.to_h.merge(item_details.to_h))
          update_cart
          render_item
        end

        def update
          update_params = params.permit(:sku, :quantity).to_h
          update_params.merge!(item_details.to_h) if params[:sku].present?

          current_order.update_item(params[:id], update_params)
          update_cart
          render_item
        end

        def destroy
          current_order.remove_item(params[:id])
          update_cart
          render_item
        end

        private

        def update_cart
          current_order.save! # trigger any validation errors to raise
          remove_unpurchasable_items
          check_inventory
          Pricing.perform(current_order, current_checkout.shipping)
        end

        def item_params
          @item_params ||= params
                             .permit(:product_id, :sku, :quantity)
                             .merge(customizations: customization_params)
        end

        def product_id
          @product_id ||= if params[:product_id].present?
            params[:product_id]
          elsif params[:sku].present?
            Catalog::Product.find_by_sku(params[:sku]).id
          elsif params[:id].present?
            current_order.items.find(params[:id]).product_id
          end
        end

        def item_details
          ActionController::Parameters.new(
            OrderItemDetails.find!(params[:sku]).to_h
          ).permit!
        end

        def customizations
          @customizations ||= Catalog::Customizations.find(
            product_id,
            params.to_unsafe_h
          )
        end

        def customization_params
          ActionController::Parameters.new(
            customizations.try(:to_h) || {}
          ).permit!
        end

        def validate_customizations
          if customizations.present? && !customizations.valid?
            flash[:error] = customizations.errors.full_messages.join(', ')
            set_flash_header
            render_item
            return false
          end
        end

        def render_item
          if current_order.items.any? && !request.delete?
            model = if params[:id].present?
              current_order.items.find(params[:id])
            else
              current_order.items.desc(:updated_at).first
            end

            @item = Workarea::Storefront::OrderItemViewModel.wrap(model)
          end

          render template: 'workarea/api/storefront/cart_items/item'
        end
      end
    end
  end
end
