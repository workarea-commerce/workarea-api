json.item do
  if @item.present?
    json.partial! 'workarea/api/storefront/orders/item', item: @item
  end
end

json.order do
  json.partial! 'workarea/api/storefront/orders/order', order: @order
end
