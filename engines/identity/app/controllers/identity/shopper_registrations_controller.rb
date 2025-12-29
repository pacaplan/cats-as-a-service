# frozen_string_literal: true

module Identity
  # Controller for shopper registration
  class ShopperRegistrationsController < Devise::RegistrationsController
    before_action :configure_permitted_parameters

    # Override create to return JSON response
    def create
      build_resource(sign_up_params)

      resource.save
      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    end

    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation, :name)
    end

    def respond_with(resource, _opts = {})
      if resource.persisted?
        render json: {
          id: resource.id,
          email: resource.email,
          name: resource.name,
          email_verified: resource.email_verified,
          created_at: resource.created_at
        }, status: :created
      else
        render json: { errors: resource.errors.messages }, status: :unprocessable_entity
      end
    end
  end
end

