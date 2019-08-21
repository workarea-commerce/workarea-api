json.taxon do
  json.partial! 'workarea/api/storefront/taxons/taxon', taxon: @taxon
end

json.children @taxon.children.select(&:active?) do |child|
  json.partial! 'workarea/api/storefront/taxons/taxon', taxon: child
end
