json.user_id current_user.id
json.addresses @addresses do |address|
  json.partial! 'workarea/api/storefront/saved_addresses/saved_address', address: address
end
