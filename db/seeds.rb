admin = User.new(email: 'admin@priceitnow.com', password: '123456', password_confirmation: '123456', role: 'admin')
admin.save!