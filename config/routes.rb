Spree::Core::Engine.add_routes do
  # Add your extension routes here
  post '/afterpay', :to => "afterpay#source", :as => :afterpay_source
  resources :afterpay, only: [] do
    member do
      get :success
      get :cancel
    end
  end
end
