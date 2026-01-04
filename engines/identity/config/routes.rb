# frozen_string_literal: true

Identity::Engine.routes.draw do
  devise_for :shopper_identities,
    class_name: "Identity::ShopperIdentityRecord",
    skip: %i[registrations sessions passwords]

  # Shopper registration endpoint
  post "users", to: "shopper_registrations#create"

  # Shopper session endpoints
  post "users/sign_in", to: "shopper_sessions#create"
  delete "users/sign_out", to: "shopper_sessions#destroy"
  get "users/current", to: "shopper_sessions#current"

  # Admin session routes (mounted at /admin via host app)
  scope :admin do
    get "sign_in", to: "admin_sessions#new", as: :admin_sign_in
    post "sign_in", to: "admin_sessions#create"
    delete "sign_out", to: "admin_sessions#destroy", as: :admin_sign_out
  end
end
