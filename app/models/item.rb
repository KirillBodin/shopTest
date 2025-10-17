class Item < ApplicationRecord
    # Связь "товар участвует во многих позициях заказа"
    has_many :order_descriptions, dependent: :restrict_with_error
    # Через позиции — связь с многими заказами
    has_many :orders, through: :order_descriptions
  
    # Название обязательно
    validates :name, presence: true
    # Цена — число >= 0
    validates :price, numericality: { greater_than_or_equal_to: 0 }
  end
  