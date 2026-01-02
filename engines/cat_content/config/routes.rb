CatContent::Engine.routes.draw do
  # Controllers follow Rails conventions and live in app/controllers
  get "health", to: "health#show"

  # Public catalog endpoints
  get "catalog", to: "cat_listings#index"
  get "catalog/:slug", to: "cat_listings#show"
  
  # Admin endpoints
  scope "admin" do
    resources :cats, controller: "admin/cats", only: [:index, :show, :create, :update, :destroy] do
      member do
        patch :publish
        patch :archive
      end
    end
  end
  
  # Custom cats endpoints
  get "custom-cats", to: "custom_cats#index"
  get "custom-cats/:id", to: "custom_cats#show"
  post "custom-cats", to: "custom_cats#create"
  post "custom-cats/:id/regenerate-description", to: "custom_cats#regenerate_description"
  delete "custom-cats/:id", to: "custom_cats#destroy"
  
  # Catbot endpoints
  post "catbot/generate", to: "catbot#generate"
  post "catbot/regenerate-description", to: "catbot#regenerate_description"
  get "catbot/quiz", to: "catbot#quiz"
  post "catbot/quiz/submit", to: "catbot#submit_quiz"
end
