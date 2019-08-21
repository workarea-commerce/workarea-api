json.cache! product.cache_key, expires_in: 1.hour do
  json.id product.id

  json.name product.name
  json.description product.description
  json.slug product.slug

  json.browser_title product.browser_title
  json.meta_description product.meta_description

  json.template product.template
  json.customizations product.customizations
  json.details product.details
  json.digital product.digital?
  json.filters product.filters
  json.purchasable product.purchasable?
  json.inventory_status product.inventory_status

  json.variants product.variants do |variant|
    json.id variant.id
    json.name variant.name
    json.sku variant.sku
    json.details variant.details
  end

  json.sell_min_price json.sell_min_price
  json.sell_max_price product.sell_max_price
  json.on_sale product.on_sale?
  json.original_min_price product.original_min_price
  json.original_max_price product.original_max_price

  json.images product.images do |image|
    json.id image.id
    json.option image.option
    json.position image.position
    json.primary image == product.primary_image
    json.partial! 'workarea/api/storefront/products/image_urls', image: image
  end

  json.append_partials('api.storefront.product_details', product: product)
end
