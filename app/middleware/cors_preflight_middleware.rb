# app/middleware/cors_preflight_middleware.rb
class CorsPreflightMiddleware
    def initialize(app)
      @app = app
    end
  
    def call(env)
      req = Rack::Request.new(env)
  
      # обрабатываем ТОЛЬКО префлайт
      if req.options?
        origin = req.get_header("HTTP_ORIGIN").to_s
        req_hdr = req.get_header("HTTP_ACCESS_CONTROL_REQUEST_HEADERS").to_s
        allowed = ENV.fetch("CLIENT_ORIGINS", ENV.fetch("CLIENT_ORIGIN", "")).split(",").map(&:strip)
  
        headers = {
          "Content-Length" => "0",
          "Vary" => "Origin"
        }
  
        if allowed.include?(origin)
          headers.merge!(
            "Access-Control-Allow-Origin" => origin,
            "Access-Control-Allow-Credentials" => "true",
            "Access-Control-Allow-Methods" => "GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD",
            "Access-Control-Allow-Headers" => (req_hdr.empty? ? "*" : req_hdr),
            "Access-Control-Max-Age" => "86400"
          )
        end
  
        return [204, headers, []]
      end
  
      @app.call(env)
    end
  end
  