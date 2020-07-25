Rails.application.routes.draw do
  root 'handbags#index'

  devise_for :users

  resources :handbags, only: [:index]
end
