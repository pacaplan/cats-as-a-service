# frozen_string_literal: true

Devise.setup do |config|
  require "devise/orm/active_record"

  # Password length: 12-128 characters
  config.password_length = 12..128

  # Case-insensitive email lookup
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  # Sign out via DELETE
  config.sign_out_via = :delete

  # No email reconfirmation for MVP
  config.reconfirmable = false

  # Expire remember me tokens on sign out
  config.expire_all_remember_me_on_sign_out = true
end
