json.id item.id
json.product_id item.product_id
json.sku item.sku
json.quantity item.quantity
json.product_url product_url(item.product, sku: item.sku)
json.options item.details
json.customizations item.customizations

json.product_image do
  json.partial! 'workarea/api/storefront/products/image_urls', image: item.image
end

json.pricing do
  json.price_adjustments item.price_adjustments do |adjustment|
    json.description adjustment.description
    json.discount adjustment.discount?
    json.amount adjustment.amount
  end

  json.total_price item.total_price
  json.on_sale item.on_sale?
  json.original_unit_price item.original_unit_price
  json.original_price item.original_price
  json.customized item.customized?
  json.customizations_unit_price item.customizations_unit_price
end
