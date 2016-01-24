Rails.application.routes.draw do
  root to: 'visitors#index'
  get '/about', to: 'visitors#about'
  get '/login', to: 'visitors#login'
  get '/download', to: 'visitors#download'
  get '/complete_registration', to: 'visitors#complete_registration'
  devise_for :users
end
