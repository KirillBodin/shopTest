Rails.application.routes.draw do
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
