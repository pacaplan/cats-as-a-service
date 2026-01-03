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

  # === LOCKABLE CONFIGURATION ===
  # Lock strategy: lock after N failed attempts
  config.lock_strategy = :failed_attempts

  # Unlock strategy: time-based only (no email unlock)
  config.unlock_strategy = :time

  # Maximum failed attempts before lock
  config.maximum_attempts = 5

  # Unlock after 1 hour
  config.unlock_in = 1.hour

  # === TIMEOUTABLE CONFIGURATION ===
  # Session expires after 24 hours of inactivity
  config.timeout_in = 24.hours
end
