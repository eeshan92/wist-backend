Rails.application.routes.draw do
  resources :locations
  resources :posts
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "home#index"

  # api
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      post 'users/me', to: 'users#me'
      resources :posts
    end
  end
end
