json.query_string @search.query_string
json.message @search.message
json.redirect @search.redirect
json.sorts @search.sorts
json.sort @search.sort

json.content_blocks @search.content.blocks do |block|
  json.partial! 'workarea/api/storefront/content_blocks/block', block: block
end

json.partial! 'workarea/api/storefront/shared/pagination', model: @search

json.facets @search.facets do |facet|
  json.partial! "workarea/api/storefront/facets/#{facet.type}", facet: facet
end

json.products @search.products do |product|
  json.partial! 'workarea/api/storefront/products/product', product: product
end
