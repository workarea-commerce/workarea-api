json.menus @menus do |menu|
  json.partial! 'workarea/api/storefront/menus/menu', menu: menu
end
