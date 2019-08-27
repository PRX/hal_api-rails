# encoding: utf-8

class HalApi::Representer < Roar::Decorator
  include Roar::Hypermedia
  include Roar::JSON::HAL
  include Roar::JSON::HAL::Links
  include Roar::JSON
  require 'roar/rails/hal'

  require 'hal_api/representer/caches'
  require 'hal_api/representer/curies'
  require 'hal_api/representer/embeds'
  require 'hal_api/representer/format_keys'
  require 'hal_api/representer/link_serialize'
  require 'hal_api/representer/uri_methods'

  include HalApi::Representer::FormatKeys
  include HalApi::Representer::UriMethods
  include HalApi::Representer::Curies
  include HalApi::Representer::Embeds
  include HalApi::Representer::Caches
  include HalApi::Representer::LinkSerialize
  self_link
  vary_link
  profile_link
end
