Spree::Core::Engine.add_routes do
  # Add your extension routes here
  resources :afterpay, only: [] do
    member do
      get :success
      get :cancel
    end
  end
end
