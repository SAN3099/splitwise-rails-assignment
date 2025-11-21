Rails.application.routes.draw do
  devise_for :users

  root to: "static#dashboard"

  get "people/:id", to: "static#person", as: :person

  resources :expenses
  resources :payments, only: [:create]
end
