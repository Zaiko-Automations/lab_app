class CreateMedicalRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :medical_requests do |t|
      t.references :webhook_receipt, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.references :requester, null: false, foreign_key: true
      t.string :conversation_id
      t.string :link_conversa
      t.string :tipo
      t.string :status
      t.datetime :validated_at
      t.integer :validated_by_id
      t.json :ai_extracted_data

      t.timestamps
    end
    add_index :medical_requests, :conversation_id
    add_index :medical_requests, :validated_by_id
  end
end
