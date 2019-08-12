json.id @recent_views.id
json.categories @recent_views.categories do |category|
  json.partial! 'workarea/api/storefront/categories/category', category: category
end
json.products @recent_views.products do |product|
  json.partial! 'workarea/api/storefront/products/product', product: product
end
