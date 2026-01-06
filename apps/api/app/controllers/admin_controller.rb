class AdminController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_admin!

  # GET /admin
  # Admin dashboard (requires authentication)
  def index
    # Renders app/views/admin/index.html.erb
  end

  private

  def authenticate_admin!
    unless warden.authenticated?(:admin_identity)
      redirect_to "/admin/sign_in"
    end
  end

  def current_admin
    warden.user(:admin_identity)
  end
end
