class Order < ApplicationRecord
  # Заказ принадлежит одному пользователю
  belongs_to :user

  # У заказа много строк (позиции), каждая ссылается на товар
  has_many :order_descriptions, dependent: :destroy
  has_many :items, through: :order_descriptions

  # Сумма заказа должна быть >= 0
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
end
