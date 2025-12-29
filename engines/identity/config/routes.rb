# frozen_string_literal: true

Identity::Engine.routes.draw do
  # Ensure Devise secret_key is set before routes are drawn
  if defined?(Devise) && Devise.secret_key.blank?
    Devise.secret_key = Rails.application.secret_key_base || 'test_secret_key_for_engine_routes_only'
  end

  # Explicitly load the model before devise_for (bypasses Zeitwerk autoloading)
  model_file = File.join(Identity::Engine.root, "app/infrastructure/identity/persistence/models/shopper_identity_record.rb")
  require model_file if File.exist?(model_file)

  devise_for :shopper_identities,
    class_name: "Identity::ShopperIdentityRecord",
    controllers: { registrations: "identity/shopper_registrations" },
    path: "users",
    only: [:registrations]
end
