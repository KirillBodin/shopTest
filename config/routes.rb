Rails.application.routes.draw do
  # health на корне (необязательно)
  get "/" => proc { [200, { "Content-Type" => "application/json" }, [{ status: "ok" }.to_json]] }

  # CORS preflight catch-all (должен быть ближе к началу)
  match "*path", via: [:options], to: "application#preflight"


  devise_for :users, defaults: { format: :json }

  namespace :api do
    namespace :v1 do
      resource :profile, only: [:show, :update]   
      resources :items
      resources :orders, only: [:index, :show, :create]
      resources :users, only: %i[index show create update destroy]                        
    end
  end
end
