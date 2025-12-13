# frozen_string_literal: true

module Errors
  module AppErrors
    class ApplicationError < StandardError
    attr_reader :status, :code, :detail

    def initialize(msg = nil, status: :unprocessable_entity, code: nil, detail: nil)
      @status = status
      @code = code || self.class.name.demodulize.underscore
      @detail = detail || msg
      super(msg)
    end

    def to_h
      {
        code: code,
        detail: detail
      }
    end
    end
end

end
