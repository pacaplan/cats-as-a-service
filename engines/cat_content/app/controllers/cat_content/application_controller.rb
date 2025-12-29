# frozen_string_literal: true

module CatContent
  class ApplicationController < ActionController::API
    rescue_from StandardError, with: :handle_internal_error

    private

    def handle_internal_error(exception)
      Rails.logger.error("Internal error: #{exception.message}")
      Rails.logger.error(exception.backtrace.join("\n"))

      render json: {
        error: "service_unavailable",
        message: "Unable to retrieve catalog. Please try again shortly."
      }, status: :service_unavailable
    end
  end
end



