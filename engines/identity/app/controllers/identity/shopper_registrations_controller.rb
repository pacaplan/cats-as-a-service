# frozen_string_literal: true

module Identity
  # Controller for shopper registration
  #
  # Primary adapter that delegates to ShopperAuthService
  class ShopperRegistrationsController < Identity::ApplicationController
    # Skip CSRF verification for API requests from external clients (e.g., Next.js frontend)
    skip_before_action :verify_authenticity_token

    # POST /users
    def create
      result = shopper_auth_service.register(
        email: registration_params[:email],
        password: registration_params[:password],
        password_confirmation: registration_params[:password_confirmation],
        name: registration_params[:name]
      )

      if result.success?
        shopper = result.value!
        record = Identity::ShopperIdentityRecord.find_by(email: shopper.email)
        sign_in(record) if record
        render json: {
          id: shopper.id,
          email: shopper.email,
          name: shopper.name,
          email_verified: shopper.email_verified,
          created_at: shopper.created_at
        }, status: :created
      else
        render json: {errors: result.failure}, status: :unprocessable_entity
      end
    end

    private

    def shopper_auth_service
      @shopper_auth_service ||= Identity::Container[:shopper_auth_service]
    end

    def registration_params
      params.require(:user).permit(:email, :password, :password_confirmation, :name)
    end
  end
end
