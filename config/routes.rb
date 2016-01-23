Rails.application.routes.draw do
  root to: 'visitors#index'
  get '/about', to: 'visitors#about'
  get '/login', to: 'visitors#login'
  get '/download', to: 'visitors#download'
  get '/logout', to: 'users#sign_out'
  devise_for :users
end
