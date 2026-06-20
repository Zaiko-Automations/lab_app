module Api
  module V1
    class WebhooksController < ActionController::API
      before_action :authenticate_token!

      def create
        # Save the raw payload
        # params.to_unsafe_h gets the raw hash of parameters including nested fields
        receipt = WebhookReceipt.create!(
          payload: params.to_unsafe_h.except(:controller, :action, :webhook),
          status: 'received'
        )

        # Enqueue the background job
        ProcessWebhookJob.perform_later(receipt.id)

        # Respond 202 Accepted immediately to prevent timeouts
        render json: {
          message: "Payload received and queued for processing",
          receipt_id: receipt.id
        }, status: :accepted
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def authenticate_token!
        token = request.headers['X-API-Token'] || request.headers['Authorization']&.split(' ')&.last
        # In development, fallback to a default token if env is not set
        expected_token = ENV['WEBHOOK_API_TOKEN'] || 'vida_lucas_secret_token_2026'

        if token.blank? || token != expected_token
          render json: { error: 'Unauthorized: Invalid or missing X-API-Token' }, status: :unauthorized
        end
      end
    end
  end
end
