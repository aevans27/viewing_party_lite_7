Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'home#index'
  get '/register', to: 'users#new'

  resources :users, only: [:new, :create, :show] do
    resources :discover, only: [:index]
    resources :movies, only: [:index, :show]
    resources :viewing_parties, only: [:index]
  end

  get "/login", to: "users#login_form"
  post "/login", to: "users#login"

  get "/users/:user_id/movies/:movid_id/viewing-party/new", to: "viewing_parties#new"
  post "/users/:user_id/movies/:movid_id/viewing-party/create", to: "viewing_parties#create"
  patch "/users/:user_id/viewing-parties/:party_id/accept_invite", to: "viewing_parties#accept_invite"
end
