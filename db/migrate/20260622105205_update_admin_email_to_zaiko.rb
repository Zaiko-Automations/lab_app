class UpdateAdminEmailToZaiko < ActiveRecord::Migration[7.1]
  def up
    user = User.find_by(email: 'admin@vida.com.br')
    user.update(email: 'admin@zaikohub.com.br') if user
  end

  def down
    user = User.find_by(email: 'admin@zaikohub.com.br')
    user.update(email: 'admin@vida.com.br') if user
  end
end
