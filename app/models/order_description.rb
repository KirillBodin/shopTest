class OrderDescription < ApplicationRecord
  # Каждая позиция принадлежит одному заказу и одному товару
  belongs_to :order
  belongs_to :item

  # Количество — целое, строго > 0
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
end
