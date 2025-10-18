class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  respond_to :json

  before_action :configure_permitted_parameters, if: :devise_controller?

  # ===== Унифицированные ответы об ошибках =====
  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { error: 'not_found', message: e.message }, status: :not_found
  end

  rescue_from ActionController::ParameterMissing do |e|
    render json: { error: 'param_missing', message: e.message }, status: :unprocessable_entity
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { error: 'validation_failed', message: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,        keys: %i[first_name last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name])
  end

  def preflight
    origin  = request.headers["Origin"].to_s
    req_hdr = request.headers["Access-Control-Request-Headers"].presence || "*"

    allowed_origins = ENV.fetch("CLIENT_ORIGINS", ENV.fetch("CLIENT_ORIGIN", "")).split(",").map(&:strip)

    if allowed_origins.include?(origin)
      headers["Access-Control-Allow-Origin"]      = origin
      headers["Vary"]                             = "Origin"
      headers["Access-Control-Allow-Credentials"] = "true"  # если используешь credentials: 'include'
      headers["Access-Control-Allow-Methods"]     = "GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD"
      headers["Access-Control-Allow-Headers"]     = req_hdr # вернём то, что просил браузер (или *)
      headers["Access-Control-Max-Age"]           = "86400"
    end

    head :no_content
  end
end
