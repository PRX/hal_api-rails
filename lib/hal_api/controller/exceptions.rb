require 'action_dispatch/http/request'
require 'action_dispatch/middleware/exception_wrapper'

# Since we are taking over exception handling, make sure we log exceptions
# https://github.com/rails/rails/blob/4-2-stable/actionpack/lib/action_dispatch/middleware/debug_exceptions.rb
module HalApi::Controller::Exceptions
  extend ActiveSupport::Concern

  def respond_with_error(exception)
    wrapper =
      if HalApi.rails_major_version >= 5
        ::ActionDispatch::ExceptionWrapper.new(ActiveSupport::BacktraceCleaner.new, exception)
      else
        ::ActionDispatch::ExceptionWrapper.new(request.env, exception)
      end

    error =
      if exception.is_a?(HalApi::Errors::ApiError) && exception.status >= 500
        log_error(request.env, wrapper)
        notice_error(exception)
        exception
      elsif exception.is_a?(HalApi::Errors::ApiError)
        exception
      else
        log_error(request.env, wrapper)
        notice_error(exception)
        HalApi::Errors::ApiError.new(exception.message).tap do |e|
          e.set_backtrace(exception.backtrace)
        end
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

    message = "\n#{exception.class} (#{exception.message}):\n"
    if exception.respond_to?(:annoted_source_code)
      ActiveSupport::Deprecation.silence do
        message << exception.annoted_source_code.to_s
      end
    end
    message << "  " << trace.join("\n  ")
    logger.fatal("#{message}\n\n")
  end

  def notice_error(error)
    if defined?(::NewRelic::Agent) && ::NewRelic::Agent.respond_to?(:notice_error)
      ::NewRelic::Agent.notice_error(error)
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
