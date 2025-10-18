# frozen_string_literal: true

require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

# Подключаем dotenv для локалки/стейджа
Dotenv::Railtie.load if defined?(Dotenv)

module ShopApi
  class Application < Rails::Application
    # Rails 8 defaults
    config.load_defaults 8.0

    # API-only, но нам нужны cookies/сессии (например, Devise)
    config.api_only = true
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore

    # Наше кастомное middleware в автозагрузке
    config.autoload_paths << Rails.root.join("app/middleware")
    config.eager_load_paths << Rails.root.join("app/middleware")
    require_relative "../app/middleware/cors_preflight_middleware"

    # ВАЖНО: порядок вставки делаем в config/initializers/cors.rb
    # (здесь НЕ вызываем insert_after Rack::Cors)

    # Игнор некоторых подпапок lib
    config.autoload_lib(ignore: %w[assets tasks])

    # Пример: часовой пояс
    # config.time_zone = "Kyiv"
  end
end
