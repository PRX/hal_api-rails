require 'roar-rails'

module HalApi::Errors

  class ApiError < StandardError
    attr_accessor :status
    attr_accessor :hint

    def initialize(message = nil, status = nil, hint = nil)
      super(message || "API Error")
      self.status = status || 500
      self.hint = hint
    end
  end

  class Forbidden < ApiError
    def initialize(message = nil, hint = nil)
      super(message || 'Forbidden', 403, hint)
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

  class BadSortError < ApiError
    def initialize(msg, hint = nil)
      super(msg, 400, hint)
    end
  end

  class UnknownFilterError < ApiError
    def initialize(msg, hint = nil)
      super(msg, 400, hint)
    end
  end

  class BadFilterValueError < ApiError
    def initialize(msg, hint = nil)
      super(msg, 400, hint)
    end
  end

  module Representer
    include Roar::JSON::HAL

    property :status
    property :message
    property :backtrace, if: -> (*) { Rails.configuration.try(:consider_all_requests_local) }
  end
end
