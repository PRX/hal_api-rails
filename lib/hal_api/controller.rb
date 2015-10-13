require 'active_support/concern'
require 'responders'
require 'roar-rails'

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

    before_action :set_accepts
    respond_to :hal, :json

    include Roar::Rails::ControllerAdditions
  end

  module ClassMethods
    include HalApi::Controller::Actions::ClassMethods
    include HalApi::Controller::Cache::ClassMethods
    include HalApi::Controller::Resources::ClassMethods
  end


  private

  def set_accepts
    request.format = :json if request.format == Mime::HTML
  end
end
