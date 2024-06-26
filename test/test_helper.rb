$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "action_controller/railtie"
require "action_view/railtie"
require 'active_support/all'

require 'responders'
require 'roar-rails'
require 'hal_api/rails'

require 'pry-byebug'
require 'minitest/autorun'

ENV['RAILS_ENV'] = 'test'

module Dummy
  class Application < Rails::Application
    config.encoding = 'utf-8'
    config.eager_load = false
    config.active_support.test_order = :random
    config.secret_key_base = '5678'
    config.active_support.cache_format_version = 7.0
  end
end
Dummy::Application.initialize!

require 'rails/test_help'
