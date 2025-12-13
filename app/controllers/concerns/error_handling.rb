# frozen_string_literal: true

module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ::Errors::AppErrors::ApplicationError, with: :handle_application_error
    rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized
    rescue_from ::Errors::Auth::InvalidToken, with: :handle_unauthenticated
    rescue_from ::Errors::Auth::Unauthorized, with: :handle_unauthenticated
    rescue_from ::Errors::Auth::RevokedToken, with: :handle_revoked_token
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

  def handle_unauthorized(_exception)
    render_error(message: "You are not authorized to perform this action", status: :forbidden, code: :forbidden)
  end

  def handle_unauthenticated(exception)
    render_error(message: exception.message, status: :unauthorized, code: :unauthorized)
  end

  def handle_revoked_token(_exception)
    render_error(message: "Token has been revoked", status: :unauthorized, code: :unauthorized)
  end
end
