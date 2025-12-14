# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # CORS origins from FRONTEND_URL environment variable
    # Supports multiple origins (comma-separated) or single origin
    origin_env = ENV["FRONTEND_URL"]
    
    origins(
      if origin_env.nil? || origin_env.empty?
        if Rails.env.production?
          raise "CORS: FRONTEND_URL environment variable must be set in production"
        else
          # Development fallback if .env.development is missing
          Rails.logger.warn("CORS: FRONTEND_URL not set. Defaulting to http://localhost:3000")
          "http://localhost:3000"
        end
      else
        # Parse comma-separated origins or use single origin
        origins_list = origin_env.split(",").map(&:strip).reject(&:empty?)
        origins_list.length == 1 ? origins_list.first : origins_list
      end
    )

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins "example.com"
#
#     resource "*",
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end