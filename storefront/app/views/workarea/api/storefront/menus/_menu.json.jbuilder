json.cache! menu.cache_key, expires_in: 1.hour do
  json.id menu.id
  json.name menu.name
  json.position menu.position
  json.url menu_path(menu)
  json.taxon_url menu.taxon.url.presence || storefront_api_url_for(menu.taxon)

  json.content_blocks menu.content.blocks do |block|
    json.partial! 'workarea/api/storefront/content_blocks/block', block: block
  end
end
