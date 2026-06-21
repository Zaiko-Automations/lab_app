require 'net/http'
require 'uri'
require 'json'

class SendCallbackWebhookJob < ApplicationJob
  queue_as :default

  def perform(medical_request_id, changes_made, validator_email)
    request = MedicalRequest.find(medical_request_id)
    patient = request.patient
    requester = request.requester
    exams = request.requested_exams

    # Build the payload
    payload = {
      conversa_id: request.conversation_id,
      link_conversa: request.link_conversa,
      tipo: request.tipo,
      status: 'validado',
      revisado_por: validator_email,
      revisado_em: request.validated_at&.iso8601 || Time.current.iso8601,
      alteracoes_realizadas: changes_made,
      paciente: {
        nome: patient.nome,
        cpf: patient.cpf,
        data_nascimento: patient.data_nascimento&.to_s,
        telefone: patient.telefone,
        whatsapp: patient.whatsapp,
        id_whatsapp: patient.id_whatsapp,
        convenio: patient.convenio,
        plano_convenio: patient.plano_convenio,
        sexo_biologico: patient.sexo_biologico,
        logradouro: patient.logradouro,
        numero: patient.numero,
        cep: patient.cep,
        bairro: patient.bairro,
        complemento: patient.complemento,
        cidade: patient.cidade,
        uf: patient.uf,
        numero_carteira: patient.numero_carteira,
        data_validade_carteira: patient.data_validade_carteira&.to_s,
        data_pedido_medico: patient.data_pedido_medico&.to_s
      },
      solicitante: {
        nome: requester.nome,
        numero_conselho: requester.numero_conselho
      },
      exames_solicitados: exams.map { |e| { codigo: e.codigo, descricao: e.descricao } }
    }

    # Dispatch Webhook
    uri = URI.parse('https://auto.zaikohub.com.br/webhook/zaikolab')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    
    # Configure timeouts (prevent infinite hangs)
    http.open_timeout = 10
    http.read_timeout = 20

    http_request = Net::HTTP::Post.new(uri.path, {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
      'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Accept-Language' => 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7'
    })
    
    http_request.body = payload.to_json

    Rails.logger.info "[Webhook Callback] Sending outbound webhook callback for MedicalRequest ##{medical_request_id} to #{uri}"
    Rails.logger.info "[Webhook Callback] Payload: #{payload.to_json}"
    
    response = http.request(http_request)

    if response.code.to_i >= 200 && response.code.to_i < 300
      Rails.logger.info "Callback webhook successfully dispatched. Status: #{response.code}"
    else
      Rails.logger.error "Callback webhook failed. Status: #{response.code}, Response: #{response.body}"
      # Raise error to let ActiveJob retry if configured
      raise "Outbound Webhook failed with status #{response.code}"
    end
  rescue => e
    Rails.logger.error "Failed to dispatch callback webhook: #{e.message}"
    raise e
  end
end
