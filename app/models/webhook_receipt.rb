class WebhookReceipt < ApplicationRecord
  has_one :medical_request, dependent: :nullify

  enum status: { received: 'received', processing: 'processing', processed: 'processed', failed: 'failed' }, _default: 'received'

  validates :payload, presence: true
end
