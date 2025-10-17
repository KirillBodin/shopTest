# app/controllers/api/v1/users_controller.rb
module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!
      before_action :require_admin!
      before_action :find_user, only: %i[show update destroy]

      rescue_from ActiveRecord::RecordNotFound do
        render json: { error: 'not_found' }, status: :not_found
      end

      # ADMIN: список всех пользователей
      def index
        users = User.order(:id)
        render json: users.as_json(only: %i[id first_name last_name email role created_at updated_at])
      end

      # ADMIN: показать одного пользователя
      def show
        render json: @user.as_json(only: %i[id first_name last_name email role created_at updated_at])
      end

      # ADMIN: создать пользователя
      def create
        user = User.new(admin_user_params)
        if user.save
          render json: user.as_json(only: %i[id first_name last_name email role created_at updated_at]),
                 status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # ADMIN: обновить пользователя
      def update
        if admin_user_params[:password].present?
          @user.update!(admin_user_params)
        else
          @user.update!(admin_user_params.except(:password, :password_confirmation))
        end

        render json: @user.as_json(only: %i[id first_name last_name email role created_at updated_at])
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      # ADMIN или ВЛАДЕЛЕЦ: удалить пользователя
      # Требует подтверждения email через ?confirm_email=... или в JSON body { confirm_email: ... }
      # Защита: нельзя удалить последнего админа.
      def destroy
        # ID может прийти как URL-параметр, так и в теле запроса
        user_id = params[:id] || params.dig(:user, :id) || params[:id].presence || params[:id]
        user = User.find(user_id)
      
        # Авторизация на уровне экшена
        unless current_user.admin? || current_user.id == user.id
          return render json: { error: 'forbidden' }, status: :forbidden
        end
      
        # Подтверждение email
        confirm_email = [
          params[:confirm_email],
          params.dig(:user, :confirm_email),
          params[:id] && params[:confirm_email],
          params[:id] && params.dig(:user, :confirm_email)
        ].compact.first.to_s.strip
      
        if confirm_email.blank? || confirm_email.downcase != user.email.downcase
          return render json: { error: 'invalid_confirmation', message: 'email does not match' },
                        status: :unprocessable_entity
        end
      
        # Нельзя удалить последнего админа
        if user.admin? && User.where(role: :admin).count == 1
          return render json: { error: 'forbidden', message: 'cannot delete the last admin' }, status: :forbidden
        end
      
        stats = {}
        ActiveRecord::Base.transaction do
          stats[:orders] = user.orders.count
          stats[:order_descriptions] = OrderDescription.where(order_id: user.orders.select(:id)).count
          user.destroy!
        end
      
        render json: {
          deleted_user_id: user.id,
          orders: stats[:orders],
          order_descriptions: stats[:order_descriptions]
        }, status: :ok
      end
      

      private

      def find_user
        @user = User.find(params[:id])
      end

      # Какие поля админ может менять/задавать
      def admin_user_params
        params.require(:user).permit(
          :first_name, :last_name, :email, :role, :password, :password_confirmation
        )
      end

      # Параметры для destroy (подтверждение email)
      def destroy_params
        params.permit(:confirm_email)
      end

      # Простейшая авторизация по роли:
      #  - админ — всегда ок
      #  - НЕ админ — разрешаем только destroy СВОЕГО аккаунта
      def require_admin!
        return if current_user&.admin?

        if action_name == 'destroy' && current_user && params[:id].to_i == current_user.id
          return
        end

        render json: { error: 'forbidden' }, status: :forbidden
      end
    end
  end
end
