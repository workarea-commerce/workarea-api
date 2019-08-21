json.cache! taxon.cache_key, expires_in: 1.day do
  json.id taxon.id
  json.url taxon_path(taxon)
  json.name taxon.name
  json.depth taxon.depth
  json.navigable_url taxon.url.presence || storefront_api_url_for(taxon)
  json.parent_id taxon.parent_id
  json.parent_ids taxon.parent_ids
  json.position taxon.position
end
