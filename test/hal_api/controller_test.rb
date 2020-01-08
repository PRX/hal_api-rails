require 'test_helper'
require 'action_controller'

describe HalApi::Controller do

  class Foo
    include ActiveModel::Model

    attr_accessor :id, :is_root_resource, :updated_at, :created_at
    cattr_accessor :_id

    self._id = 1

    def self.find(*_args)
      Foo.new.tap do |f|
        f.id = _id
        self._id += 1
        f.updated_at = DateTime.parse('1970-01-01 00:01:00')
      end
    end

    def self.inject(*args, &block)
      self._id = 1
      [find, find].inject(*args, &block)
    end

    def self.order(*_args); self; end
    def self.page(*_args); self; end
    def self.per(*_args); self; end
    def self.where(*_args); self; end
    def self.build; new; end
  end

  class FooRepresenter
  end

  class FoosController < ActionController::Base
    include HalApi::Controller

    cattr_accessor :_caches_action

    attr_accessor :_respond_with, :request, :params

    def params
      @params ||= ActionController::Parameters.new(action: 'update', id: 1)
    end

    def request
      @request ||= OpenStruct.new('put?' => false, 'post?' => false)
    end

    def respond_with(*args)
      self._respond_with = args
    end

    def self.caches_action(action, options = {})
      self._caches_action ||= {}
      self._caches_action[action] = options
    end
  end

  let (:controller) { FoosController.new }

  describe 'errors' do
    it 'handles invalid content type errors' do
      _(lambda do
        controller.create
      end).must_raise Roar::Rails::UnsupportedMediaType
    end
  end

  describe 'instance methods' do

    it 'retrieves resource' do
      _(controller.send(:resource)).must_be_instance_of Foo
    end

    it 'retrieves new resource when id not found' do
      controller.params = ActionController::Parameters.new(action: 'create')
      controller.request = OpenStruct.new('put?' => false, 'post?' => true)
      _(controller.send(:resource)).must_be_instance_of Foo
      _(controller.send(:resource).id).must_be_nil
    end

    it 'determines resource id for caching' do
      _(controller.send(:show_cache_path)).must_equal 60
    end

    it 'determines the resources id for caching' do
      cache_key = 'c/foos/1a8ca71da20c9dc2dfc2e02485821d9b'
      _(controller.send(:index_cache_path)).must_equal cache_key
    end

    it 'responds to show request' do
      controller.show
      _(controller._respond_with).wont_be_nil
      _(controller._respond_with.first).must_be_instance_of Foo
      _(controller._respond_with.last[:_keys]).must_equal []
    end

    it 'authorizes the resource' do
      assert controller.send(:hal_authorize, {})
      assert controller.send(:authorize, {})
    end

    describe "#show_cache_path" do
      let(:some_foo) { Foo.find }

      it "returns a path based on an updated_at timestamp" do
        _(controller.send(:show_cache_path)).must_equal 60
      end

      it "returns a path based on created_at if updated_at is nil" do
        some_foo.updated_at = nil
        some_foo.created_at = DateTime.parse('1970-01-01 00:00:30')
        controller.stub(:resource, some_foo) do
          _(controller.send(:show_cache_path)).must_equal 30
        end
      end
      it "uses the current time if update_at and created_at are nil" do
        some_foo.updated_at = nil
        some_foo.created_at = nil
        controller.stub(:resource, some_foo) do
          controller.stub(:current_time, DateTime.parse('1970-01-01 00:05:33')) do
            _(controller.send(:show_cache_path)).must_equal 333
          end
        end
      end
    end
  end

  describe 'class methods' do

    it 'determines class for resource' do
      _(FoosController.resource_class).must_equal Foo
    end

    it 'can specify filter params' do
      FoosController.filter_resources_by(:bar_id)
      _(FoosController.resources_params).must_equal [:bar_id]
    end

    it 'can specify representer' do
      FoosController.represent_with(FooRepresenter)
      _(FoosController.resource_representer).must_equal FooRepresenter
    end

    it 'specify allowed params for an action' do
      FoosController.allow_params :index, [:page, :per, :zoom]

      _(FoosController.valid_params).must_equal(index: [:page, :per, :zoom])
      _(FoosController.valid_params_list(:index)).must_equal([:page, :per, :zoom])
    end

    it 'sets default cache options' do
      default_opts = { compress: true, expires_in: 1.hour, race_condition_ttl: 30 }
      _(FoosController.cache_options).must_equal(default_opts)
    end

    it 'caches api actions' do
      FoosController.cache_api_action(:index, bar: true)
      _(FoosController._caches_action[:index][:bar]).must_equal true
    end
  end
end
