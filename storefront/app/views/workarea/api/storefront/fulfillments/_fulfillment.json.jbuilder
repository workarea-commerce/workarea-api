json.status order.try(:fulfillment_status)

json.packages order.packages do |package|
  json.tracking_number package.tracking_number
  json.tracking_link package.tracking_link

  json.items package.items do |item|
    json.partial! 'workarea/api/storefront/orders/item', item: item
  end
end

json.pending_items order.pending_items do |item|
  json.partial! 'workarea/api/storefront/orders/item', item: item
end

json.canceled_items order.canceled_items do |item|
  json.partial! 'workarea/api/storefront/orders/item', item: item
end
