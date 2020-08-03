Rails.application.routes.draw do
  root 'handbags#dashboard'

  devise_for :users

  resources :handbags, only: [:index] do
    collection do
      get :dashboard
      post :filter
    end
  end

  get '/users', to: 'users#index'
  delete '/user/:id/destroy', to: 'users#destroy', as: :destroy_user
end
