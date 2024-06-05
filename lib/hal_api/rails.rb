require "hal_api/rails/version"
require "hal_api"

module HalApi::Rails
  require "responders"

  Mime::Type.register "application/hal+json", :hal

  ::ActionController::Renderers.add :hal do |obj, options|
    self.content_type ||= Mime[:hal]
    obj
  end
end
