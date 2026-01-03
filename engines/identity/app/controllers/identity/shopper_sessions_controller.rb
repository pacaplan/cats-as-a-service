# frozen_string_literal: true

module Identity
  # Controller for shopper sign-in and sign-out
  #
  # Primary adapter that delegates to ShopperAuthService
  class ShopperSessionsController < Identity::ApplicationController
    # Skip CSRF verification for API requests from external clients (e.g., Next.js frontend)
    skip_before_action :verify_authenticity_token

    # POST /users/sign_in
    def create
      result = shopper_auth_service.sign_in(
        email: sign_in_params[:email],
        password: sign_in_params[:password]
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
        }, status: :ok
      else
        handle_sign_in_failure(result.failure)
      end
    end

    # DELETE /users/sign_out
    def destroy
      sign_out(current_shopper_identity_record)
      render json: {message: "Signed out successfully"}, status: :ok
    end

    # GET /users/current
    def current
      if current_shopper_identity_record
        shopper = ShopperIdentityMapper.to_domain(current_shopper_identity_record)
        render json: {
          id: shopper.id,
          email: shopper.email,
          name: shopper.name,
          email_verified: shopper.email_verified,
          created_at: shopper.created_at
        }, status: :ok
      else
        render json: {error: "Not authenticated"}, status: :unauthorized
      end
    end

    private

    def shopper_auth_service
      @shopper_auth_service ||= Identity::Container[:shopper_auth_service]
    end

    def sign_in_params
      params.require(:user).permit(:email, :password)
    end

    def current_shopper_identity_record
      warden.user(:shopper_identity)
    end

    def handle_sign_in_failure(failure)
      case failure
      when :account_suspended
        render json: {error: "Your account has been suspended"}, status: :unauthorized
      when :account_locked
        render json: {
          error: "Your account is locked due to too many failed attempts. Please try again in 1 hour."
        }, status: :unauthorized
      else
        render json: {error: "Invalid email or password"}, status: :unauthorized
      end
    end
  end
end
