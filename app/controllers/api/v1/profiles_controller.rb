# app/controllers/api/v1/profiles_controller.rb
module Api
    module V1
      class ProfilesController < ApplicationController
        before_action :authenticate_user!
  
        # Единый формат ошибок
        rescue_from ActiveRecord::RecordInvalid do |e|
          render json: { error: 'validation_failed', message: e.record.errors.full_messages }, status: :unprocessable_entity
        end
  
        # GET /api/v1/profile
        def show
          render json: current_user.as_json(only: [:id, :email, :first_name, :last_name, :role, :created_at, :updated_at])
        end
  
        # PATCH /api/v1/profile
        #
        # Правила:
        # - role менять нельзя;
        # - пароль ОПЦИОНАЛЕН: меняем только если пришли И password, И password_confirmation;
        #   если пришло одно из них — просто игнорируем смену пароля, обновляем остальные поля.
        def update
          pwd      = params.dig(:user, :password).to_s
          pwd_conf = params.dig(:user, :password_confirmation).to_s
  
          attrs = profile_params # first_name, last_name, email, (password, password_confirmation)
  
          if pwd.present? && pwd_conf.present?
            # пользователь хочет сменить пароль — обновляем как есть (валидируется Devise)
            if current_user.update(attrs)
              render json: current_user.as_json(only: [:id, :email, :first_name, :last_name, :role, :created_at, :updated_at])
            else
              render json: { error: 'validation_failed', message: current_user.errors.full_messages }, status: :unprocessable_entity
            end
          else
            # пароль неполный или пустой — игнорируем его, обновляем остальное
            sanitized = attrs.except(:password, :password_confirmation)
            if current_user.update(sanitized)
              render json: current_user.as_json(only: [:id, :email, :first_name, :last_name, :role, :created_at, :updated_at])
            else
              render json: { error: 'validation_failed', message: current_user.errors.full_messages }, status: :unprocessable_entity
            end
          end
        end
  
        private
  
        def profile_params
          # role намеренно НЕ разрешаем — её меняет только админ через /api/v1/users
          params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
        end
      end
    end
  end
  