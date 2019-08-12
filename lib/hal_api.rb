module HalApi
  require 'hal_api/paged_collection'
  require 'hal_api/errors'
  require 'hal_api/controller'
  require 'hal_api/represented_model'
  require 'hal_api/responders/api_responder'

  def self.rails_major_version
    ::Rails.version.split('.')[0].to_i
  end
end
