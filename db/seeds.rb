# === Пользователи ===
admin = User.find_or_create_by!(email: 'admin@example.com') do |u|
  u.first_name = 'Admin'
  u.last_name  = 'User'
  u.password   = 'password'
  u.password_confirmation = 'password'
  u.role       = :admin
end

user = User.find_or_create_by!(email: 'user@example.com') do |u|
  u.first_name = 'John'
  u.last_name  = 'Doe'
  u.password   = 'password'
  u.password_confirmation = 'password'
  u.role       = :user
end

# === Товары ===
Item.find_or_create_by!(name: 'iPhone 15') do |i|
  i.description = 'Apple smartphone'
  i.price = 999.00
end

Item.find_or_create_by!(name: 'MacBook Air') do |i|
  i.description = 'M2 13-inch'
  i.price = 1299.00
end

Item.find_or_create_by!(name: 'AirPods Pro') do |i|
  i.description = 'Noise cancelling earbuds'
  i.price = 249.00
end

puts "✅ Database seeded successfully!"
puts "👑 Admin: #{admin.first_name} #{admin.last_name} (#{admin.email}) / password"
puts "👤 User:  #{user.first_name} #{user.last_name} (#{user.email}) / password"
puts "📦 Items count: #{Item.count}"
