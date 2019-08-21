json.account do
  json.partial! 'workarea/api/storefront/accounts/account', user: @user
end

json.authentication_token do
  json.partial! 'workarea/api/storefront/authentication_tokens/authentication_token', authentication_token: @authentication_token
end
