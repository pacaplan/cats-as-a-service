# frozen_string_literal: true

module Identity
  class ApplicationController < ActionController::Base
    # Devise requires ActionController::Base for session management
    
    # Enable JSON parsing
    protect_from_forgery with: :null_session
  end
end
