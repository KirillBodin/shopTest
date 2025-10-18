# frozen_string_literal: true

require "rack/cors"

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Берём список доменов из ENV (через запятую)
    raw = ENV.fetch("CLIENT_ORIGINS", ENV.fetch("CLIENT_ORIGIN", ""))
    allowed_origins = raw.split(",").map(&:strip).reject(&:empty?)

    # РЕЖИМЫ:
    # - В development, если список пуст — разрешаем всем (без credentials).
    # - Во всех остальных случаях — явно перечисленные домены + credentials: true.
    if allowed_origins.empty? && Rails.env.development?
      origins "*"
      resource "*",
        headers: :any,
        methods: %i[get post put patch delete options head],
        expose: %w[Authorization],
        credentials: false,      # при '*' credentials ДОЛЖНЫ быть false
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
