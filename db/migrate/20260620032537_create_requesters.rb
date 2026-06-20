class CreateRequesters < ActiveRecord::Migration[7.1]
  def change
    create_table :requesters do |t|
      t.string :nome
      t.string :numero_conselho

      t.timestamps
    end
    add_index :requesters, :numero_conselho
  end
end
