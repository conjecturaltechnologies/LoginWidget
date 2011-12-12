CloudFoundryRailsTutorial::Application.routes.draw do
  resources :messages
  root :to => "messages#index"
  
  resources :letters
  root :to => "letters#index"
end
