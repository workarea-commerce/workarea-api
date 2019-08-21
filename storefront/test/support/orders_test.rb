module Workarea
  module Api
    module Storefront
      module OrdersTest
        def add_item(order, params)
          order.add_item(
            OrderItemDetails
              .find!(params[:sku])
              .to_h
              .merge(params)
          )

          Pricing.perform(order)
        end
      end
    end
  end
end
