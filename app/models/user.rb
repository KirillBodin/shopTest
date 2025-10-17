class User < ApplicationRecord
  # Модули Devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # Роли. ВАЖНО: всё в одну строку, без переносов и лишних "enum".
  # Правильно для Rails 8:
enum :role, { user: 0, admin: 1 }, default: :user, validate: true


  has_many :orders, dependent: :destroy

  # Простая заглушка для ревокации JWT (на старте достаточно)
  def self.jwt_revoked?(_payload, _user); false; end
  def self.revoke_jwt(_payload, _user); end

  validates :first_name, :last_name, presence: true
end
