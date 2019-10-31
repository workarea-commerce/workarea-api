Rails.application.routes.draw do
  mount Workarea::Core::Engine => '/'
  mount Workarea::Admin::Engine => '/admin', as: 'admin'
  mount Workarea::Storefront::Engine => '/', as: 'storefront'
  mount_workarea_api at: '/api'
end
