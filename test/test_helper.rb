$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "action_controller/railtie"
require "action_view/railtie"
require 'active_support/all'

require 'responders'
require 'roar-rails'
require 'hal_api/rails'

require 'minitest/spec'
require 'minitest/autorun'
