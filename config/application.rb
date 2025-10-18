require_relative "boot"
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Подключаем dotenv для переменных окружения
Dotenv::Railtie.load if defined?(Dotenv)

module ShopApi
  class Application < Rails::Application
    # Настройки по умолчанию для Rails 8
    config.load_defaults 8.0

    # === Загрузка и регистрация нашего кастомного middleware ===
    # Явно подключаем файл
    require_relative "../app/middleware/cors_preflight_middleware"

    # Добавляем пути к middleware в автозагрузку
    config.autoload_paths << Rails.root.join("app/middleware")
    config.eager_load_paths << Rails.root.join("app/middleware")

    # Вставляем CorsPreflightMiddleware самым первым — до Rack::Cors и всего остального
    config.middleware.insert_before 0, ::CorsPreflightMiddleware

    # === Настройки API ===
    config.api_only = true

    # Включаем cookies и сессии (Devise их требует)
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore

    # Игнорируем ненужные поддиректории lib
    config.autoload_lib(ignore: %w[assets tasks])

    # Пример: можно задать временную зону
    # config.time_zone = "Kyiv"
  end
end
