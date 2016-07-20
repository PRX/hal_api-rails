require 'action_dispatch/http/request'
require 'action_dispatch/middleware/exception_wrapper'

# Since we are taking over exception handling, make sure we log exceptions
# https://github.com/rails/rails/blob/4-2-stable/actionpack/lib/action_dispatch/middleware/debug_exceptions.rb
module HalApi::Controller::Exceptions
  def respond_with_error(exception)
    wrapper = ::ActionDispatch::ExceptionWrapper.new(env, exception)
    log_error(env, wrapper)

    error = if exception.is_a?(HalApi::Errors::ApiError)
              exception
            else
              e = HalApi::Errors::ApiError.new(exception.message)
              e.set_backtrace(exception.backtrace)
              e
            end

    respond_with(
      error,
      status: error.status,
      location: nil, # for POST requests
      represent_with: HalApi::Errors::Representer
    )
  end

  def log_error(env, wrapper)
    logger = env['action_dispatch.logger'] || self.logger || ActiveSupport::Logger.new($stderr)
    return unless logger

    exception = wrapper.exception

    trace = wrapper.application_trace
    trace = wrapper.framework_trace if trace.empty?

    ActiveSupport::Deprecation.silence do
      message = "\n#{exception.class} (#{exception.message}):\n"
      message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)
      message << "  " << trace.join("\n  ")
      logger.fatal("#{message}\n\n")
    end
  end

  module ClassMethods
    def hal_rescue_standard_errors
      rescue_from StandardError do |error|
        respond_with_error(error)
      end
    end
  end
end
