require 'test_helper'

describe HalApi::Controller::Exceptions < ActionController::TestCase do
  include ActiveSupport::Testing::SetupAndTeardown
  include ActionController::TestCase::Behavior

  class TestRoutes
    def extra_keys(*any) []; end
    def path_for(*any) ''; end
  end

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
    @controller = ExceptionsTestController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @routes = TestRoutes.new
  end

  it 'rescues from standard errors' do
    get :throwerror, {format: :hal}
    response.status.must_equal 500
    json = JSON.parse(response.body)
    json['status'].must_equal 500
    json['message'].must_equal 'what now'
    json.key?('backtrace').must_equal false
  end

  it 'optionally shows backtraces' do
    Rails.configuration.consider_all_requests_local = true
    get :throwerror, {format: :hal}
    json = JSON.parse(response.body)
    json.key?('backtrace').must_equal true
    json['backtrace'].must_be_instance_of Array
  end

  it 'does not try to set a location header for post errors' do
    post :throwerror, {format: :hal}
    response.status.must_equal 500
    json = JSON.parse(response.body)
    json['status'].must_equal 500
    json['message'].must_equal 'what now'
    response.headers['Location'].must_be_nil
  end

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

    it 'notices 500 errors if newrelic exists' do
      notice = MiniTest::Mock.new
      notice.expect :call, nil do |err|
        err.message == 'what now'
      end
      NewRelic::Agent.stub :notice_error, notice do
        get :throwerror, {format: :hal}
        response.status.must_equal 500
        notice.verify
      end
    end

    it 'does not notice 400 errors' do
      notice = -> { raise StandardError.new('should not have called this') }
      NewRelic::Agent.stub :notice_error, notice do
        get :thrownotfound, {format: :hal}
        response.status.must_equal 404
      end
    end

  end
end
