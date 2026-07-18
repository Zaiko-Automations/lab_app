class MedicalRequest < ApplicationRecord
  belongs_to :webhook_receipt, optional: true
  belongs_to :patient
  belongs_to :requester
  belongs_to :validated_by, class_name: 'User', optional: true

  has_many :requested_exams, dependent: :destroy

  accepts_nested_attributes_for :patient
  accepts_nested_attributes_for :requester
  accepts_nested_attributes_for :requested_exams, allow_destroy: true

  has_one_attached :documento
  has_one_attached :pedido_medico
  has_many_attached :pedidos_medicos
  has_one_attached :carteira_convenio

  enum status: { pending: 'pending', validated: 'validated' }, _default: 'pending'

  validates :conversation_id, presence: true
end
