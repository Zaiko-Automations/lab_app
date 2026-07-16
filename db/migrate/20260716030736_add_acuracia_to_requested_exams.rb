class AddAcuraciaToRequestedExams < ActiveRecord::Migration[7.1]
  def change
    add_column :requested_exams, :acuracia, :string
  end
end
