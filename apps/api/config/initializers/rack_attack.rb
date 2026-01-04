# frozen_string_literal: true

class Rack::Attack
  # Throttle registration attempts by IP address
  throttle("registrations/ip", limit: 5, period: 1.minute) do |req|
    if req.post? && (req.path == "/api/users" || req.path == "/users")
      req.ip
    end
  end

  # Throttle sign-in attempts by IP address
  throttle("sign_in/ip", limit: 5, period: 1.minute) do |req|
    if req.post? && (req.path == "/api/users/sign_in" || req.path == "/users/sign_in")
      req.ip
    end
  end

  # Throttle admin sign-in attempts by IP address (5 requests/minute)
  throttle("admin_sign_in/ip", limit: 5, period: 1.minute) do |req|
    if req.post? && req.path == "/admin/sign_in"
      req.ip
    end
  end
end

# Return 429 status for throttled requests
Rack::Attack.throttled_responder = lambda do |env|
  match_data = env["rack.attack.match_data"]
  now = match_data[:epoch_time]

  headers = {
    "Content-Type" => "application/json",
    "X-RateLimit-Limit" => match_data[:limit].to_s,
    "X-RateLimit-Remaining" => "0",
    "X-RateLimit-Reset" => (now + (match_data[:period] - now % match_data[:period])).to_s
  }

  [429, headers, [{error: "Too many requests. Please try again later."}.to_json]]
end
