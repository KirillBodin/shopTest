# frozen_string_literal: true

require_relative "boot"
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Подключаем dotenv для переменных окружения (локально/стейдж)
Dotenv::Railtie.load if defined?(Dotenv)

module ShopApi
  class Application < Rails::Application
    # Настройки по умолчанию для Rails 8
    config.load_defaults 8.0

    # Приложение работает как API, но нам нужны cookies/сессии (например, Devise)
    config.api_only = true
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore

    # === Наше кастомное middleware ===
    # Путь к файлу и автозагрузка
    require_relative "../app/middleware/cors_preflight_middleware"
    config.autoload_paths << Rails.root.join("app/middleware")
    config.eager_load_paths << Rails.root.join("app/middleware")

    # === Порядок middleware критичен ===
    # 1) Rack::Cors — САМЫМ ПЕРВЫМ (ставим в cors.rb через insert_before 0)
    # 2) Наш preflight — СРАЗУ ПОСЛЕ Rack::Cors, чтобы не гасить CORS-заголовки
    config.middleware.insert_after Rack::Cors, ::CorsPreflightMiddleware

    # Игнорируем ненужные поддиректории lib
    config.autoload_lib(ignore: %w[assets tasks])

    # Пример: часовой пояс
    # config.time_zone = "Kyiv"
  end
end
