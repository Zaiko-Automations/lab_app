class CreateWebhookReceipts < ActiveRecord::Migration[7.1]
  def change
    create_table :webhook_receipts do |t|
      t.json :payload
      t.string :status
      t.text :error_message
      t.datetime :processed_at

      t.timestamps
    end
  end
end
