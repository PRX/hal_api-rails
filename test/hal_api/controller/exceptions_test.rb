require 'test_helper'

describe HalApi::Controller::Exceptions do

  include ActionDispatch::IntegrationTest::Behavior

  class ExceptionsTestController < ActionController::Base
    include Roar::Rails::ControllerAdditions
    include HalApi::Controller::Exceptions

    respond_to :hal
    rescue_from StandardError do |error| respond_with_error(error); end

    def throwerror
      raise StandardError.new('what now')
    end
    def thrownotfound
      raise HalApi::Errors::NotFound.new
    end
  end

  before do
    Rails.configuration.consider_all_requests_local = false
    Rails.application.routes.draw do
      get '/throwerror', to: 'exceptions_test#throwerror'
      post '/throwerror', to: 'exceptions_test#throwerror'
      get '/thrownotfound', to: 'exceptions_test#thrownotfound'
    end
  end
  after do
    Rails.application.reload_routes!
  end

  it 'rescues from standard errors' do
    get '/throwerror.hal'
    _(response.status).must_equal 500
    json = JSON.parse(response.body)
    _(json['status']).must_equal 500
    _(json['message']).must_equal 'what now'
    _(json.key?('backtrace')).must_equal false
  end

  it 'optionally shows backtraces' do
    Rails.configuration.consider_all_requests_local = true
    get '/throwerror.hal'
    json = JSON.parse(response.body)
    _(json.key?('backtrace')).must_equal true
    _(json['backtrace']).must_be_instance_of Array
  end

  it 'does not try to set a location header for post errors' do
    post '/throwerror.hal'
    _(response.status).must_equal 500
    json = JSON.parse(response.body)
    _(json['status']).must_equal 500
    _(json['message']).must_equal 'what now'
    _(response.headers['Location']).must_be_nil
  end
  #
  describe 'with new relic defined' do

    before do
      module NewRelic; end
      module NewRelic::Agent
        def self.notice_error; end
      end
    end

    after do
      Object.send(:remove_const, :NewRelic)
    end

    it 'notices 500 errors' do
      notice = Minitest::Mock.new
      notice.expect :call, nil do |err|
        err.message == 'what now'
      end
      NewRelic::Agent.stub :notice_error, notice do
        get '/throwerror.hal'
        _(response.status).must_equal 500
        notice.verify
      end
    end

    it 'does not notice 400 errors' do
      notice = -> { raise StandardError.new('should not have called this') }
      NewRelic::Agent.stub :notice_error, notice do
        get '/thrownotfound.hal'
        _(response.status).must_equal 404
      end
    end

  end
end
