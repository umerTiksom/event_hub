class Rack::Attack
  throttle("login/ip", limit: 5, period: 1.minute) do |req|
    req.ip if req.post? && req.path == "/api/v1/auth/login"
  end

  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"]

    retry_after = match_data[:period] - (match_data[:epoch_time] % match_data[:period])

    [
      429,
      {
        "Content-Type" => "application/json",
        "Retry-After" => retry_after.to_s
      },
      [
        {
          status: "error",
          message: "Too many requests. Please try again later."
        }.to_json
      ]
    ]
  end
end