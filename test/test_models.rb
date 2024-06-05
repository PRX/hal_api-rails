require "hal_api/representer"
require "active_model/naming"

TestObject = Struct.new(:title, :is_root_resource) do
  extend ActiveModel::Naming

  def persisted?
    false
  end

  def to_model
    self
  end

  def to_param
    "1"
  end

  def id
    1
  end

  def id=(_id)
    _id
  end
end

TestParent = Struct.new(:id, :is_root_resource) do
  extend ActiveModel::Naming

  def persisted?
    false
  end

  def to_model
    self
  end

  def to_param
    "#{id}"
  end
end

class TestOption
  def initialize(v)
    @value = v
  end

  def evaluate(c = nil)
    @value
  end
end

module Api
  class BaseRepresenter < HalApi::Representer
    curies(:test) do
      [{
        name: :test,
        href: "http://#{profile_host}/relation/{rel}",
        templated: true
      }]
    end

    def self.alternate_host
      "www.test.dev"
    end

    def self.profile_host
      "meta.test.dev"
    end
  end

  class TestObjectRepresenter < BaseRepresenter
    property :title

    def api_tests_path(rep)
      title = rep.respond_to?(:[]) ? rep[:title] : rep.try(:title)
      "/api/tests/#{title}"
    end

    def self_url(rep)
      title = rep.respond_to?(:[]) ? rep[:title] : rep.try(:title)
      "/api/tests/#{title}"
    end
  end

  class Api::TestParentRepresenter < BaseRepresenter
    property :id
  end

  module Min
    class TestObjectRepresenter < BaseRepresenter
      property :title

      def api_tests_path(rep)
        title = rep.respond_to?(:[]) ? rep[:title] : rep.try(:title)
        "/api/tests/#{title}"
      end
    end
  end

  class TestObjectsController < ActionController::Base
    def index
      head :no_content
    end

    def show
      head :no_content
    end

    def create
      head :no_content
    end

    def update
      head :no_content
    end

    def destroy
      head :no_content
    end

    def resource
      @resource ||= TestObject.new("title", true)
    end

    def parent
      @parent ||= TestParent.new(1, true)
    end
  end

  class Api::TestParentsController < ActionController::Base
    def index
      head :no_content
    end

    def show
      head :no_content
    end

    def create
      head :no_content
    end

    def update
      head :no_content
    end

    def destroy
      head :no_content
    end

    def resource
      @resource ||= TestParent.new(1, true)
    end
  end
end

def define_routes
  Rails.application.routes.draw do
    namespace :api do
      resources :test_objects

      resources :test_parents do
        get "test_objects", to: "test_objects#index"
      end
    end
  end
end

class Foo
  include ActiveModel::Model
  attr_accessor :id, :is_root_resource, :updated_at, :created_at
  cattr_accessor :_id

  self._id = 1

  def self.find(*_args)
    Foo.new.tap do |f|
      f.id = _id
      self._id += 1
      f.updated_at = DateTime.parse("1970-01-01 00:01:00")
    end
  end

  def self.inject(*, &)
    self._id = 1
    [find, find].inject(*, &)
  end

  def self.order(*_args)
    self
  end

  def self.page(*_args)
    self
  end

  def self.per(*_args)
    self
  end

  def self.where(*_args)
    self
  end

  def self.build
    new
  end
end

class FooRepresenter
  def self.prepare(_model)
    FooRepresenter.new
  end

  def from_json(str, opt)
    Foo.new
  end
end

class FoosController < ActionController::Base
  include HalApi::Controller

  cattr_accessor :_caches_action

  attr_accessor :_respond_with, :request, :params

  def params
    @params ||= ActionController::Parameters.new(action: "update", id: 1)
  end

  def request
    @request ||= OpenStruct.new("put?" => false, "post?" => false, "content_type" => "application/json")
  end

  def respond_with(*args)
    self._respond_with = args
  end

  def self.caches_action(action, options = {})
    self._caches_action ||= {}
    self._caches_action[action] = options
  end
end
