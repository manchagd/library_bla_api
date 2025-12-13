# frozen_string_literal: true

module ResponseHandling
  extend ActiveSupport::Concern

  def render_response(data:, status: :ok, meta: {})
    payload = {
      data: data,
      errors: []
    }
    payload[:meta] = meta if meta.present?

    render json: payload, status: status
  end
end
