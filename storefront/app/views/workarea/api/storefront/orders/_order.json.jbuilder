json.id order.id
json.url order_url(order)
json.user_id order.user_id
json.email order.email
json.placed_at order.placed_at
json.canceled_at order.canceled_at
json.promo_codes order.promo_codes
json.requires_shipping order.requires_shipping?

json.items order.items do |item|
  json.partial! 'workarea/api/storefront/orders/item', item: item
end

json.pricing do
  json.price_adjustments order.total_adjustments do |adjustment|
    json.description adjustment.description.titleize
    json.amount adjustment.amount
  end

  json.shipping_total order.shipping_total
  json.tax_total order.tax_total
  json.subtotal_price order.subtotal_price
  json.total_price order.total_price
  json.paid_amount order.try(:paid_amount) || 0
end

json.shipping_service order.shipping_service
json.shipping_address do
  if order.shipping_address.present?
    json.partial! 'workarea/api/storefront/shared/address', address: order.shipping_address
  end
end

json.billing_address do
  if order.billing_address.present?
    json.partial! 'workarea/api/storefront/shared/address', address: order.billing_address
  end
end

json.tenders order.tenders do |tender|
  json.partial! "workarea/api/storefront/orders/tenders/#{tender.slug}", tender: tender
end
