require 'roar-rails'

module HalApi::Errors

  class ApiError < StandardError
    attr_accessor :status

    def initialize(message = nil, status = 500)
      super(message || "API Error")
      self.status = status
    end
  end

  class NotFound < ApiError
    def initialize(message = nil)
      super(message || "Resource Not Found", 404)
    end
  end

  class UnsupportedMediaType < ApiError
    def initialize(type)
      super("Unsupported Media Type '#{type.inspect}'", 415)
    end
  end

  class UnknownFilterError < NoMethodError
  end

  class BadFilterValueError < ApiError
    def initialize(msg)
      super(msg, 400)
    end
  end

  module Representer
    include Roar::JSON::HAL

    property :status
    property :message
    property :backtrace, if: -> (*) { Rails.configuration.try(:consider_all_requests_local) }
  end
end
