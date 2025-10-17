module Api
    module V1
      class OrdersController < ApplicationController
        # Пускать только авторизованных (Devise проверит JWT и выставит current_user)
        before_action :authenticate_user!
        # Перед show найдём заказ
        before_action :set_order, only: :show
  
        # GET /api/v1/orders
        # user -> видит только свои; admin -> видит все
        def index
          orders =
            if current_user.admin?
              # includes подгружает связанные записи, чтобы не делать N+1 запросов
              Order.includes(order_descriptions: :item).all
            else
              current_user.orders.includes(order_descriptions: :item)
            end
  
          # as_json с include — простой способ вернуть вложенные позиции и товары
          render json: orders.as_json(include: { order_descriptions: { include: :item } })
        end
  
        # GET /api/v1/orders/:id
        def show
          # Проверка доступа: владелец или админ
          unless current_user.admin? || @order.user_id == current_user.id
            return render json: { error: 'forbidden' }, status: :forbidden
          end
  
          render json: @order.as_json(include: { order_descriptions: { include: :item } })
        end
  
        # POST /api/v1/orders
        # Тело запроса (JSON):
        # {
        #   "items": [
        #     { "item_id": 1, "quantity": 2 },
        #     { "item_id": 3, "quantity": 1 }
        #   ]
        # }
        def create
          items_payload = Array(params[:items])
          # Если список пустой — ошибка
          return render json: { error: 'items required' }, status: :unprocessable_entity if items_payload.empty?
  
          # Транзакция: либо всё создастся, либо ничего
          ActiveRecord::Base.transaction do
            total = 0
            lines = []
  
            # Считаем сумму на сервере (клиенту не доверяем)
            items_payload.each do |row|
              item_id = row[:item_id] || row['item_id']
              qty     = (row[:quantity] || row['quantity']).to_i
  
              # элементарная проверка
              return render(json: { error: 'quantity must be > 0' }, status: :unprocessable_entity) if qty <= 0
  
              item = Item.find(item_id) # бросит 404, если id неверный
              total += item.price * qty
              lines << [item, qty]
            end
  
            # создаём шапку заказа
            order = current_user.orders.create!(amount: total)
  
            # создаём строки заказа
            lines.each do |(item, qty)|
              order.order_descriptions.create!(item: item, quantity: qty)
            end
  
            # отдаём созданный заказ с позициями
            render json: order.as_json(include: { order_descriptions: { include: :item } }), status: :created
          end
        end
  
        private
  
        def set_order
          # includes — подгружает связанные позиции и товары
          @order = Order.includes(order_descriptions: :item).find(params[:id])
        end
      end
    end
  end
  