require 'stringio'
require 'open-uri'

class ProcessWebhookJob < ApplicationJob
  queue_as :default

  def perform(webhook_receipt_id)
    receipt = WebhookReceipt.find(webhook_receipt_id)
    receipt.update!(status: 'processing')

    payload = receipt.payload.deep_symbolize_keys

    # Extract sections
    conversa_id = payload[:conversa_id]
    link_conversa = payload[:link_conversa]
    tipo = payload[:tipo]
    paciente_data = payload[:paciente] || {}
    solicitante_data = payload[:solicitante] || {}
    exames_data = payload[:exames_solicitados] || []
    imagens_data = payload[:imagens] || {}

    # We do a transaction to ensure all database writes succeed together
    ActiveRecord::Base.transaction do
      # 1. Find or create Patient by CPF (clean of formatting)
      cpf_clean = paciente_data[:cpf].to_s.gsub(/\D/, '')
      
      patient = if cpf_clean.present?
                  Patient.find_or_initialize_by(cpf: cpf_clean)
                else
                  Patient.new
                end

      patient.assign_attributes(
        nome: paciente_data[:nome],
        data_nascimento: paciente_data[:data_nascimento],
        telefone: paciente_data[:telefone],
        whatsapp: paciente_data[:whatsapp],
        id_whatsapp: paciente_data[:id_whatsapp],
        convenio: paciente_data[:convenio],
        plano_convenio: paciente_data[:plano_convenio],
        sexo_biologico: paciente_data[:sexo_biologico],
        logradouro: paciente_data[:logradouro],
        numero: paciente_data[:numero],
        cep: paciente_data[:cep],
        bairro: paciente_data[:bairro],
        complemento: paciente_data[:complemento],
        cidade: paciente_data[:cidade],
        uf: paciente_data[:uf],
        numero_carteira: paciente_data[:numero_carteira],
        data_validade_carteira: paciente_data[:data_validade_carteira],
        data_pedido_medico: paciente_data[:data_pedido_medico]
      )
      
      # Save patient (ignoring strict validations if we want to save partial data, but since we have validations, 
      # we'll save it. In case it's invalid, we will let transaction fail and record the error)
      patient.save!

      # 2. Find or create Requester by Conselho number
      conselho = solicitante_data[:numero_conselho].to_s.strip
      requester = if conselho.present?
                    Requester.find_or_initialize_by(numero_conselho: conselho)
                  else
                    Requester.new
                  end
      requester.nome = solicitante_data[:nome] || 'Desconhecido'
      requester.save!

      # 3. Create Medical Request
      # We prepare a clean AI extracted data snapshot (excluding raw base64 images)
      ai_snapshot = payload.except(:imagens)

      medical_request = MedicalRequest.create!(
        webhook_receipt: receipt,
        patient: patient,
        requester: requester,
        conversation_id: conversa_id,
        link_conversa: link_conversa,
        tipo: tipo,
        status: 'pending',
        ai_extracted_data: ai_snapshot
      )

      # 4. Create Requested Exams
      exames_data.each do |exam|
        next if exam[:descricao].blank? && exam[:codigo].blank? # Skip empty exams
        medical_request.requested_exams.create!(
          codigo: exam[:codigo],
          descricao: exam[:descricao]
        )
      end

      # 5. Decode and attach base64 images
      attach_base64(medical_request, :documento, imagens_data[:documento], "documento_#{conversa_id}.jpg")
      attach_base64(medical_request, :pedido_medico, imagens_data[:pedido_medico], "pedido_medico_#{conversa_id}.jpg")
      attach_base64(medical_request, :carteira_convenio, imagens_data[:carteira_convenio], "carteira_convenio_#{conversa_id}.jpg")
    end

    receipt.update!(status: 'processed', processed_at: Time.current)
  rescue => e
    receipt.update!(status: 'failed', error_message: "#{e.class}: #{e.message}\n#{e.backtrace.join("\n")}")
    raise e # Re-raise to let the job queue runner know (e.g. Sidekiq/ActiveJob)
  end

  private

  def attach_base64(record, attachment_name, base64_string, filename)
    return if base64_string.blank? || base64_string.length < 50 # Ignore invalid/placeholder strings

    if base64_string.start_with?('data:')
      # Format is data:image/jpeg;base64,...
      match = base64_string.match(/^data:([^;]+);base64,(.*)$/m)
      return unless match

      content_type = match[1]
      base64_data = match[2]
    else
      content_type = 'image/jpeg'
      base64_data = base64_string
    end

    begin
      decoded_data = Base64.decode64(base64_data)
      io = StringIO.new(decoded_data)
      
      record.public_send(attachment_name).attach(
        io: io,
        filename: filename,
        content_type: content_type
      )
    rescue => e
      Rails.logger.error "Failed to attach base64 file #{filename}: #{e.message}"
    end
  end
end
