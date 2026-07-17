class AddEspecialidadeToMedicalRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :medical_requests, :especialidade, :string
  end
end
