class MedicalRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_medical_request, only: [:show, :validate]

  def index
    @status = params[:status] || 'pending'
    @medical_requests = MedicalRequest.includes(:patient, :requester)
                                      .where(status: @status)
                                      .order(created_at: :desc)

    if params[:search].present?
      search_term = "%#{params[:search].strip}%"
      @medical_requests = @medical_requests.joins(:patient)
        .where("patients.nome LIKE :search OR patients.cpf LIKE :search OR medical_requests.conversation_id LIKE :search", search: search_term)
    end
  end

  def show
    @ai_data = @medical_request.ai_extracted_data || {}
  end

  def validate
    # We do updates inside a transaction
    ActiveRecord::Base.transaction do
      if @medical_request.update(medical_request_params)
        # Calculate diff before marking validated
        changes = calculate_changes(@medical_request)

        # Mark as validated
        @medical_request.update!(
          status: 'validated',
          validated_at: Time.current,
          validated_by: current_user
        )

        # Enqueue background webhook callback
        SendCallbackWebhookJob.perform_later(@medical_request.id, changes, current_user.email)

        redirect_to root_path(status: 'pending'), notice: "Pedido de #{@medical_request.patient.nome} verificado e validado com sucesso!"
      else
        @ai_data = @medical_request.ai_extracted_data || {}
        flash.now[:alert] = "Não foi possível salvar as alterações: #{@medical_request.errors.full_messages.join(', ')}"
        render :show
      end
    end
  end

  private

  def set_medical_request
    @medical_request = MedicalRequest.find(params[:id])
  end

  def medical_request_params
    params.require(:medical_request).permit(
      :tipo, :conversation_id, :link_conversa,
      patient_attributes: [
        :id, :nome, :cpf, :data_nascimento, :telefone, :whatsapp, :id_whatsapp,
        :convenio, :plano_convenio, :sexo_biologico, :logradouro, :numero, :cep,
        :bairro, :complemento, :cidade, :uf, :numero_carteira,
        :data_validade_carteira, :data_pedido_medico
      ],
      requester_attributes: [
        :id, :nome, :numero_conselho
      ],
      requested_exams_attributes: [
        :id, :codigo, :descricao, :_destroy
      ]
    )
  end

  def calculate_changes(request)
    ai_data = request.ai_extracted_data&.deep_symbolize_keys || {}
    changes = {}

    # Patient diff
    ai_patient = ai_data[:paciente] || {}
    patient = request.patient
    patient_diff = {}

    fields = [
      :nome, :cpf, :data_nascimento, :telefone, :whatsapp, :id_whatsapp,
      :convenio, :plano_convenio, :sexo_biologico, :logradouro, :numero, :cep,
      :bairro, :complemento, :cidade, :uf, :numero_carteira,
      :data_validade_carteira, :data_pedido_medico
    ]

    fields.each do |field|
      original_val = ai_patient[field].to_s.strip
      current_val = patient.send(field).to_s.strip

      # Normalize booleans
      if field == :whatsapp
        original_val = (original_val == 'true' || original_val == '1').to_s
        current_val = (current_val == 'true' || current_val == '1').to_s
      end

      if original_val != current_val
        patient_diff[field] = { de: original_val.presence || "(vazio)", para: current_val.presence || "(vazio)" }
      end
    end
    changes[:paciente] = patient_diff if patient_diff.any?

    # Requester diff
    ai_requester = ai_data[:solicitante] || {}
    requester = request.requester
    requester_diff = {}

    [:nome, :numero_conselho].each do |field|
      original_val = ai_requester[field].to_s.strip
      current_val = requester.send(field).to_s.strip
      if original_val != current_val
        requester_diff[field] = { de: original_val.presence || "(vazio)", para: current_val.presence || "(vazio)" }
      end
    end
    changes[:solicitante] = requester_diff if requester_diff.any?

    changes
  end
end
