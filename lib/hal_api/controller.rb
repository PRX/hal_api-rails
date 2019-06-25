require 'active_support/concern'
require 'responders'
require 'roar-rails'

module HalApi::Controller
  extend ActiveSupport::Concern

  require 'hal_api/controller/actions'
  require 'hal_api/controller/cache'
  require 'hal_api/controller/resources'
  require 'hal_api/controller/exceptions'

  include HalApi::Controller::Actions
  include HalApi::Controller::Cache
  include HalApi::Controller::Resources
  include HalApi::Controller::Exceptions

  included do
    include Roar::Rails::ControllerAdditions

    before_action :set_accepts
    respond_to :hal, :json

    hal_rescue_standard_errors
  end

  private

  def set_accepts
    mime_comparator = case HalApi::rails_major_version
                      when 5
                        Mime[:html]
                      else
                        Mime::HTML
                      end
    request.format = :json if request.format == mime_comparator
  end

  def env
    case HalApi.rails_major_version
    when 5
      request.env
    else
      super
    end
  end
end
