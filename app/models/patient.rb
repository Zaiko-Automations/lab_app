class Patient < ApplicationRecord
  has_many :medical_requests, dependent: :destroy

  validates :nome, presence: true
  validates :cpf, presence: true
  validate :cpf_is_valid
  validate :telefone_is_valid

  private

  def cpf_is_valid
    return if cpf.blank?

    clean_cpf = cpf.gsub(/\D/, '')

    unless clean_cpf.length == 11 && !clean_cpf.match(/^(.)\1{10}$/) && cpf_checksum_valid?(clean_cpf)
      errors.add(:cpf, 'não é válido')
    end
  end

  def cpf_checksum_valid?(clean_cpf)
    digits = clean_cpf.chars.map(&:to_i)
    
    # 1st digit
    sum = 0
    9.times { |i| sum += digits[i] * (10 - i) }
    mod = sum % 11
    d1 = mod < 2 ? 0 : 11 - mod
    return false if digits[9] != d1

    # 2nd digit
    sum = 0
    10.times { |i| sum += digits[i] * (11 - i) }
    mod = sum % 11
    d2 = mod < 2 ? 0 : 11 - mod
    return false if digits[10] != d2

    true
  end

  def telefone_is_valid
    return if telefone.blank?

    clean_phone = telefone.gsub(/\D/, '')
    unless clean_phone.length == 10 || clean_phone.length == 11
      errors.add(:telefone, 'deve ter 10 ou 11 dígitos (incluindo DDD)')
    end
  end
end
