# frozen_string_literal: true

Identity::Engine.routes.draw do
  # Shopper registration endpoint
  post "users", to: "shopper_registrations#create"
end
