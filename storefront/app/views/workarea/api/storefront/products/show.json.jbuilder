json.cache! @product.cache_key, expires_in: 1.hour do
  json.product do
    json.partial! 'workarea/api/storefront/products/product', product: @product
  end

  json.recommendations @product.recommendations do |product|
    json.partial! 'workarea/api/storefront/products/product', product: product
  end
end
