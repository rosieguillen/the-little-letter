Rails.application.routes.draw do
root "storefront#index"
get "categories/:slug", to: "storefront#index", as: :category
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :products, only: [:show]
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  get "admin", to: "admin_access#show", as: :admin_dashboard
  get "admin/sign-in", to: "admin_access#new", as: :admin_sign_in
  post "admin/sign-in", to: "admin_access#create"
  delete "admin/sign-out", to: "admin_access#destroy", as: :admin_sign_out

  resources :products, controller: "admin_products", only: [:new, :create, :edit, :update]
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
    scope path: "/admin", as: "admin" do
    resources :products, controller: "admin_products",
      only: [:new, :create, :edit, :update, :destroy]
    resources :categories, controller: "admin_categories",
      only: [:index, :create, :edit, :update]
  end

  get "cart", to: "cart#show", as: :cart
  post "cart/items", to: "cart#add", as: :cart_items
  patch "cart/items/:product_id", to: "cart#update", as: :cart_item
  delete "cart/items/:product_id", to: "cart#remove"

  get "checkout", to: "checkout#new", as: :checkout
  post "checkout/review", to: "checkout#review", as: :review_checkout
end
