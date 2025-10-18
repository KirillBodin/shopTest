# config/initializers/cors.rb
require "rack/cors"

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # поддержка нескольких Origin из ENV
    allowed_origins = ENV.fetch("CLIENT_ORIGINS", ENV.fetch("CLIENT_ORIGIN", "")).split(",").map(&:strip).reject(&:empty?)

    # если переменная не задана — на всякий случай ничего не разрешаем
    # (лучше явно указать домены ниже в ENV)
    origins(*allowed_origins)

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose: %w[Authorization],
      credentials: true,         # важно, если фронт шлёт credentials
      max_age: 86400
  end
end
