# frozen_string_literal: true

require "rack/cors"
# На случай, если файл middleware не был загружен ранее
require Rails.root.join("app/middleware/cors_preflight_middleware")

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Берём домены из ENV (через запятую)
    raw = ENV.fetch("CLIENT_ORIGINS", ENV.fetch("CLIENT_ORIGIN", ""))
    allowed_origins = raw.split(",").map(&:strip).reject(&:empty?)

    # В dev, если переменные не заданы — разрешаем всех (без credentials).
    if allowed_origins.empty? && Rails.env.development?
      origins "*"
      resource "*",
        headers: :any,
        methods: %i[get post put patch delete options head],
        expose: %w[Authorization],
        credentials: false,      # при '*' ДОЛЖНО быть false
        max_age: 86_400
    else
      origins(*allowed_origins)
      resource "*",
        headers: :any,
        methods: %i[get post put patch delete options head],
        expose: %w[Authorization],
        credentials: true,       # cookies/JWT разрешены только при явных origins
        max_age: 86_400
    end
  end
end

# Теперь, когда Rack::Cors уже вставлен, можно безопасно вставить наш preflight-процессор СРАЗУ ПОСЛЕ него
Rails.application.config.middleware.insert_after Rack::Cors, ::CorsPreflightMiddleware
