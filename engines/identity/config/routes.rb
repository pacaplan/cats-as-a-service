# frozen_string_literal: true

Identity::Engine.routes.draw do
  devise_for :shopper_identities,
             class_name: "Identity::ShopperIdentityRecord",
             skip: %i[registrations sessions passwords]

  # Shopper registration endpoint
  post "users", to: "shopper_registrations#create"
end
