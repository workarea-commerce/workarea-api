json.cache! @page.cache_key, expires_in: 1.hour do
  json.id @page.id
  json.name @page.name
  json.url page_url(@page)

  json.browser_title @page.browser_title
  json.meta_description @page.meta_description

  json.breadcrumbs @page.breadcrumbs do |taxon|
    json.partial! 'workarea/api/storefront/taxons/taxon', taxon: taxon
  end

  json.content_blocks @page.content.blocks.select(&:active?) do |block|
    json.partial! 'workarea/api/storefront/content_blocks/block', block: block
  end
end
