json.cache! @category.cache_key, expires_in: 1.hour do
  json.id @category.id
  json.name @category.name
  json.slug @category.slug
  json.url category_url(@category)

  json.browser_title @category.browser_title
  json.meta_description @category.meta_description

  json.sorts @category.sorts
  json.sort @category.sort

  json.breadcrumbs @category.breadcrumbs do |taxon|
    json.partial! 'workarea/api/storefront/taxons/taxon', taxon: taxon
  end

  json.content_blocks @category.content.blocks.select(&:active?) do |block|
    json.partial! 'workarea/api/storefront/content_blocks/block', block: block
  end

  json.partial! 'workarea/api/storefront/shared/pagination', model: @category

  json.facets @category.facets do |facet|
    json.partial! "workarea/api/storefront/facets/#{facet.type}", facet: facet
  end

  json.products @category.products do |product|
    json.partial! 'workarea/api/storefront/products/product', product: product
  end
end
