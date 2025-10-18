# frozen_string_literal: true
require "rack/cors"

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '*',
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose: %w[Authorization],
      credentials: false,  # при '*' обязательно false
      max_age: 86_400
  end
end
