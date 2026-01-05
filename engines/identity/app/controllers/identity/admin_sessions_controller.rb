# frozen_string_literal: true

module Identity
  # Controller for admin sign-in and sign-out
  #
  # Uses Rails views (ERB templates), not JSON API.
  # Primary adapter that delegates to AdminAuthService.
  class AdminSessionsController < Identity::ApplicationController
    layout "identity/admin"

    # GET /admin/sign_in
    def new
      @error = flash[:error]
    end

    # POST /admin/sign_in
    def create
      result = admin_auth_service.sign_in(
        username: sign_in_params[:username],
        password: sign_in_params[:password]
      )

      if result.success?
        admin = result.value!
        record = Identity::AdminIdentityRecord.find_by(id: admin.id)

        if record
          sign_in(:admin_identity, record)
          redirect_to "/admin", notice: "Signed in successfully"
        else
          # Record not found - should never happen, but handle gracefully
          flash[:error] = "Authentication error. Please try again."
          redirect_to admin_sign_in_path
        end
      else
        handle_sign_in_failure(result.failure)
      end
    end

    # DELETE /admin/sign_out
    def destroy
      sign_out(:admin_identity)
      redirect_to admin_sign_in_path, notice: "Signed out successfully"
    end

    private

    def admin_auth_service
      @admin_auth_service ||= Identity::Container[:admin_auth_service]
    end

    def sign_in_params
      params.require(:admin).permit(:username, :password)
    end

    def handle_sign_in_failure(failure)
      error_message = case failure
      when :account_locked
        "Your account is locked due to too many failed attempts. Please try again in 1 hour."
      else
        "Invalid username or password"
      end

      flash[:error] = error_message
      redirect_to admin_sign_in_path
    end
  end
end
