json.cache! @content.cache_key, expires_in: 1.hour do
  json.id @content.id
  json.name @content.name
  json.url system_content_url(@content.name)

  json.browser_title @content.browser_title
  json.meta_description @content.meta_description

  json.content_blocks @content.content.blocks.select(&:active?) do |block|
    json.partial! 'workarea/api/storefront/content_blocks/block', block: block
  end
end
