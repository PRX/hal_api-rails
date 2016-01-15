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

  module ClassMethods
    include HalApi::Controller::Actions::ClassMethods
    include HalApi::Controller::Cache::ClassMethods
    include HalApi::Controller::Resources::ClassMethods
    include HalApi::Controller::Exceptions::ClassMethods
  end

  private

  def set_accepts
    request.format = :json if request.format == Mime::HTML
  end
end
