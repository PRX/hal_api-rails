require 'hal_api/representer'
require 'active_model/naming'

TestObject = Struct.new(:title, :is_root_resource) do
  extend ActiveModel::Naming

  def persisted?
    false
  end

  def to_model
    self
  end

  def to_param
    '1'
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

module Api

  class BaseRepresenter < HalApi::Representer
    curies(:test) do
      [{
        name: :test,
        href: "http://#{profile_host}/relation/{rel}",
        templated: true
      }]
    end

    def self.alternate_host; "www.test.dev"; end
    def self.profile_host; "meta.test.dev"; end
  end

  class TestObjectRepresenter < BaseRepresenter
    property :title

    def api_tests_path(rep)
      title = rep.respond_to?('[]') ? rep[:title] : rep.try(:title)
      "/api/tests/#{title}"
    end

    def self_url(rep)
      title = rep.respond_to?('[]') ? rep[:title] : rep.try(:title)
      "/api/tests/#{title}"
    end
  end

  module Min
    class TestObjectRepresenter < BaseRepresenter
      property :title

      def api_tests_path(rep)
        title = rep.respond_to?('[]') ? rep[:title] : rep.try(:title)
        "/api/tests/#{title}"
      end
    end
  end

  class TestObjectsController < ActionController::Base
    def index; head :no_content; end
    def show; head :no_content; end
    def create; head :no_content; end
    def update; head :no_content; end
    def destroy; head :no_content; end

    def resource
      @resource ||= TestObject.new('title', true)
    end
  end
end

def define_routes
  Rails.application.routes.draw do
    namespace :api do
      resources :test_objects

      resources :test_parents do
        get 'test_objects', to: 'test_objects#index'
      end
    end
  end
end
