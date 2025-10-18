# config/initializers/cors.rb
require "rack/cors"

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    allowed = ENV.fetch("CLIENT_ORIGINS", ENV.fetch("CLIENT_ORIGIN", "*"))
                .split(",")
                .map { _1.strip }

    origins(*allowed)

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose: %w[Authorization],
      credentials: true # важно, если фронт шлёт credentials: "include"
  end
end
