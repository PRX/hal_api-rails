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

  module Representer
    include Roar::JSON::HAL

    property :status
    property :message
  end
end
