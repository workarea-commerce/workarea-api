Workarea::Api::Admin::Engine.routes.draw do
  basic_crud = [:index, :create, :show, :update, :destroy]
  embedded_crud = basic_crud - [:show]
  read_only = basic_crud - [:create, :update, :destroy]

  get '/', to: 'application#root', as: :root # hack because Rails doesn't have a way to get engine root path
  get '/swagger', to: 'swagger#index'

  resources :content_assets, only: basic_crud do
    collection { patch 'bulk' }
  end
  resources :categories, only: basic_crud do
    collection { patch 'bulk' }
    resources :product_rules, only: embedded_crud, controller: 'category_product_rules'
  end
  resources :content, only: basic_crud - [:destroy] do
    collection { patch 'bulk' }
  end
  resources :discounts, only: basic_crud
  resources :email_shares, only: read_only
  resources :email_signups, only: read_only
  resources :fulfillments, only: read_only do
    member do
      post 'ship_items'
      post 'cancel_items'
    end
  end
  resources :inventory_skus, only: basic_crud do
    collection { patch 'bulk' }
  end
  resources :navigation_taxons, only: basic_crud do
    collection { patch 'bulk' }
  end
  resources :navigation_menus, only: basic_crud
  resources :orders, only: read_only
  resources :pages, only: basic_crud do
    collection { patch 'bulk' }
  end
  resources :payments, only: read_only
  resources :payment_profiles, only: basic_crud do
    collection { patch 'bulk' }
    resources :saved_credit_cards, only: basic_crud do
      collection { patch 'bulk' }
    end
  end
  resources :payment_transactions, only: read_only
  resources :pricing_skus, only: basic_crud do
    collection { patch 'bulk' }
    resources :prices, only: embedded_crud
  end
  resources :products, only: basic_crud do
    collection { patch 'bulk' }
    resources :variants, only: embedded_crud
    resources :images, only: embedded_crud, controller: 'product_images'
    resource :recommendation_settings, only: [:show, :update]
  end
  resources :promo_code_lists, only: basic_crud do
    collection { patch 'bulk' }
  end
  resources :redirects, only: basic_crud do
    collection { patch 'bulk' }
  end
  resources :releases, only: basic_crud do
    collection { patch 'bulk' }
  end
  resources :shipping_skus, only: basic_crud do
    collection { patch 'bulk' }
  end
  resources :shippings, only: read_only
  resources :shipping_services, only: basic_crud do
    collection { patch 'bulk' }
    resources :rates, only: embedded_crud, controller: 'shipping_rates'
  end
  resources :tax_categories, only: basic_crud do
    collection { patch 'bulk' }
    resources :rates, only: basic_crud, controller: 'tax_rates' do
      collection { patch 'bulk' }
    end
  end
  resources :users, only: basic_crud do
    collection { patch 'bulk' }
    resources :saved_addresses, only: embedded_crud
  end
end
