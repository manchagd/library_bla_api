# frozen_string_literal: true

module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from AppErrors::ApplicationError, with: :handle_application_error
  end

  private

  def handle_standard_error(exception)
    Rails.logger.error(exception)
    render_error(
      message: "Internal Server Error",
      status: :internal_server_error,
      code: :internal_server_error
    )
  end

  def handle_not_found(exception)
    render_error(
      message: exception.message,
      status: :not_found,
      code: :not_found
    )
  end

  def handle_application_error(exception)
    render json: {
      data: {},
      errors: [exception.to_h]
    }, status: exception.status
  end

  def render_error(message:, status:, code:)
    render json: {
      data: {},
      errors: [
        {
          code: code,
          detail: message
        }
      ]
    }, status: status
  end
end
