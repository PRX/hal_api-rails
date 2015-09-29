require 'active_support/concern'

module HalApi::Controller
  extend ActiveSupport::Concern

  require 'hal_api/controller/actions'
  require 'hal_api/controller/cache'
  require 'hal_api/controller/resources'

  include HalApi::Controller::Actions
  include HalApi::Controller::Cache
  include HalApi::Controller::Resources

  included do
    rescue_from HalApi::Errors::UnsupportedMediaType do |e|
      respond_with e, status: e.status, represent_with: HalApi::Errors::Representer
    end
  end

  module ClassMethods
    include HalApi::Controller::Actions::ClassMethods
    include HalApi::Controller::Cache::ClassMethods
    include HalApi::Controller::Resources::ClassMethods
  end
end
