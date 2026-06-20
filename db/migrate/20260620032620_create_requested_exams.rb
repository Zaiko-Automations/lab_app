class CreateRequestedExams < ActiveRecord::Migration[7.1]
  def change
    create_table :requested_exams do |t|
      t.references :medical_request, null: false, foreign_key: true
      t.string :codigo
      t.string :descricao

      t.timestamps
    end
  end
end
