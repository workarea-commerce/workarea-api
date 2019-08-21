json.user_id current_user.id
json.orders @orders do |order|
  json.partial! 'workarea/api/storefront/orders/order', order: order
end
