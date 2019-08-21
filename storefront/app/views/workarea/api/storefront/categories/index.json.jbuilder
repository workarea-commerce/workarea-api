json.categories @categories do |category|
  json.partial! 'workarea/api/storefront/categories/category', category: category
end
