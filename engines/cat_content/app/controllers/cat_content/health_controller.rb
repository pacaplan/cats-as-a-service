# frozen_string_literal: true

module CatContent
  class HealthController < ActionController::API
    # GET /catalog/health
    # Health check endpoint for the CatContent engine
    # Verifies database connectivity to the cat_content schema
    def show
      db_healthy = check_database

      status = db_healthy ? :ok : :service_unavailable

      render json: {
        service: "cat_content",
        status: db_healthy ? "healthy" : "unhealthy",
        timestamp: Time.current.iso8601,
        checks: {
          database: {
            status: db_healthy ? "connected" : "disconnected",
            schema: "cat_content"
          }
        }
      }, status: status
    end

    private

    def check_database
      # Verify we can connect and query the cat_content schema
      ::BaseRecord.connection.execute("SELECT 1")
      true
    rescue StandardError => e
      Rails.logger.error("CatContent health check failed: #{e.message}")
      false
    end
  end
end


