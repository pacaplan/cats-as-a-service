# frozen_string_literal: true

require "dry/monads"

module Identity
  # Application service for AdminIdentity operations
  #
  # Orchestrates domain logic for admin authentication.
  class AdminAuthService < Rampart::Application::Service
    include Dry::Monads[:result]

    # Minimum password length for generated passwords
    PASSWORD_LENGTH = 24

    def initialize(admin_identity_repo:)
      @admin_identity_repo = admin_identity_repo
    end

    # Provision a new admin (for rake task only)
    #
    # @param username [String]
    # @return [Result<{admin: AdminIdentity, password: String}>]
    def provision(username:)
      return Failure(:username_blank) if username.to_s.strip.empty?
      return Failure(:username_exists) if @admin_identity_repo.username_exists?(username)

      password = generate_secure_password

      result = @admin_identity_repo.create(username: username, password: password)

      if result.success?
        Success({admin: result.value!, password: password})
      else
        result
      end
    rescue => e
      Failure(e.message)
    end

    # Authenticate an admin
    #
    # @param username [String]
    # @param password [String]
    # @return [Result<AdminIdentity>]
    def sign_in(username:, password:)
      @admin_identity_repo.authenticate(username: username, password: password)
    rescue => e
      Failure(e.message)
    end

    private

    def generate_secure_password
      # Generate 24+ character password with mixed case, numbers, symbols
      chars = [
        ("a".."z").to_a,
        ("A".."Z").to_a,
        ("0".."9").to_a,
        %w[! @ # $ % ^ & * ( ) - _ = + [ ] { } | ; : , . < > ?]
      ]

      # Ensure at least one of each type
      password = chars.map { |set| set.sample }.join

      # Fill remaining with random from all
      all_chars = chars.flatten
      (PASSWORD_LENGTH - 4).times { password += all_chars.sample }

      # Shuffle to randomize positions
      password.chars.shuffle.join
    end
  end
end
