require "hal_api/rails/version"
require "hal_api"

module HalApi::Rails
  require "responders"

  Mime::Type.register 'application/hal+json', :hal

  # roar fix for 4.1
  # https://github.com/apotonick/roar-rails/issues/65
  ActionController.add_renderer :hal do |js, options|
    self.content_type ||= Mime::HAL
    js.to_json
  end
end
