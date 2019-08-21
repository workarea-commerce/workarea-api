Workarea::Api::Storefront::Engine.routes.draw do
  resource :account, except: [:new, :edit, :destroy]

  post 'analytics/category_view/:category_id', to: 'analytics#category_view', as: :analytics_category_view
  post 'analytics/product_view/:product_id', to: 'analytics#product_view', as: :analytics_product_view
  post 'analytics/search', to: 'analytics#search', as: :analytics_search
  post 'analytics/search_abandonment', to: 'analytics#search_abandonment', as: :analytics_search_abandonment
  post 'analytics/filters', to: 'analytics#filters', as: :analytics_filters

  resource :authentication_tokens, only: [:create, :update]
  resources :assets, only: :show
  resources :categories, only: [:index, :show]
  resources :contacts, only: :create
  resources :orders, only: [:index, :show]
  resources :pages, only: :show
  resource :recent_views, only: [:show, :update]
  resources :saved_addresses, except: [:new, :edit]
  resources :saved_credit_cards, except: [:new, :edit]
  resource :search, only: :show
  resources :searches, only: :index
  resources :system_content, only: :show
  resources :menus, only: [:index, :show]
  resource :email_signups, only: [:show, :create]
  resources :password_resets, only: :create
  resources :products, only: :show
  resource :recommendations, only: :show
  resources :taxons, only: :show

  resources :carts, only: [:index, :show, :create] do
    resources :items, only: [:create, :update, :destroy], controller: :cart_items
    member { post 'add_promo_code', as: :add_promo_code_to }
  end

  resources :checkouts, only: [:show, :update] do
    member do
      get 'start'
      get 'reset'
      post 'complete'
    end
  end
end
