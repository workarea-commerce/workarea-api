json.order do
  json.partial! 'workarea/api/storefront/orders/order', order: @order
end

json.fulfillment do
  json.partial! 'workarea/api/storefront/fulfillments/fulfillment', order: @order
end
