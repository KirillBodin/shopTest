module Api
    module V1
      class ItemsController < ApplicationController
        # Пускать только авторизованных (Devise проверит JWT из заголовка Authorization)
       
  
        # Найти товар перед show/update/destroy
        before_action :set_item, only: %i[show update destroy]
  
        # Запретить создание/изменение/удаление не-админу
        before_action :require_admin!, only: %i[create update destroy]
  
        # GET /api/v1/items?q=iphone
        def index
          # 1) достаём q из query string (?q=...)
          q = params[:q].to_s.strip
  
          # 2) базовый запрос — все товары
          scope = Item.all
  
          # 3) если задан q — ищем по name/description (ILIKE = регистронезависимо в Postgres)
          scope = scope.where("name ILIKE :q OR description ILIKE :q", q: "%#{q}%") if q.present?
  
          # 4) вернуть JSON (Rails сам сериализует массив объектов)
          render json: scope
        end
  
        # GET /api/v1/items/:id
        def show
          render json: @item
        end
  
        # POST /api/v1/items
        # body JSON: { "item": { "name": "...", "description": "...", "price": 123.45 } }
        def create
          item = Item.create!(item_params)
          render json: item, status: :created
        end
  
        # PATCH/PUT /api/v1/items/:id
        def update
          @item.update!(item_params)
          render json: @item
        end
  
        # DELETE /api/v1/items/:id
        def destroy
          @item.destroy!
          head :no_content
        end
  
        private
  
        # Находим запись по :id из URL
        def set_item
          @item = Item.find(params[:id])
        end
  
        # "Strong parameters" — фильтруем входные поля (защита от мусора/лишних полей)
        def item_params
          params.require(:item).permit(:name, :description, :price)
        end
  
        # Простая авторизация по роли
        def require_admin!
          render json: { error: 'forbidden' }, status: :forbidden unless current_user&.admin?
        end
      end
    end
  end
  