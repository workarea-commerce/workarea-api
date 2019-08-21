json.products @recommendations.products do |product|
  json.partial! 'workarea/api/storefront/products/product', product: product
end
