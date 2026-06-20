# Create initial admin user
User.find_or_create_by!(email: 'admin@vida.com.br') do |user|
  user.password = 'vida@2026'
  user.password_confirmation = 'vida@2026'
  puts "Created initial admin user: admin@vida.com.br / vida@2026"
end
