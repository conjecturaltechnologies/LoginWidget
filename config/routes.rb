CloudFoundryRailsTutorial::Application.routes.draw do
  get "user/signup"

  get "user/login"

  get "user/logout"

  get "user/delete"

  get "user/edit"

  get "user/forgot_password"

  resources :messages
  root :to => "messages#index"
  
  resources :letters
  root :to => "letters#index"
end
