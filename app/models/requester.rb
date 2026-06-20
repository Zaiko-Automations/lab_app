class Requester < ApplicationRecord
  has_many :medical_requests, dependent: :destroy

  validates :nome, presence: true
end
