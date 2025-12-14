CatContent::Engine.routes.draw do
  # Controllers follow Rails conventions and live in app/controllers
  get "health", to: "health#show"

  # Public catalog endpoints
  get "catalog", to: "catalog#index"
  get "catalog/:slug", to: "catalog#show"
end
