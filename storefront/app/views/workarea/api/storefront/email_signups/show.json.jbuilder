json.title @email_signup.title
json.content_blocks @email_signup.content.blocks.select(&:active?) do |block|
  json.partial! 'workarea/api/storefront/content_blocks/block', block: block
end
