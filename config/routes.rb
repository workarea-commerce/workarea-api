Workarea::Api::Engine.routes.draw do
  mount Workarea::Api::Admin::Engine => '/admin', as: 'admin_api'
  mount Workarea::Api::Storefront::Engine => '/storefront', as: 'storefront_api'
  mount Workarea::Api::Documentation => '/docs' unless Rails.env.production?
end
