Rails.application.routes.draw do
  get "game", to: "gaming#game"

  get "score", to: "gaming#score"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
