# encoding: utf-8
require 'test_helper'
require 'test_models'

class TestUriMethods
  include HalApi::Representer::UriMethods
  def self.alternate_host; "www.test.dev"; end
  def self.profile_host; "meta.test.dev"; end
end

class AltTestUriMethods
  include HalApi::Representer::UriMethods
  self.alternate_host = "alt.www.test.dev"
  self.profile_host = "alt.meta.test.dev"
end

class ChildTestUriMethods < AltTestUriMethods
end

class BaseModelTest
  def self.base_class; Class; end
end

class Widget < BaseModelTest
end

class VerySpecialThing < Widget
end

class SpecialWidget < Widget
end

describe HalApi::Representer::UriMethods do

  let(:helper) { TestUriMethods.new }
  let(:alt_helper) { AltTestUriMethods.new }
  let(:child_helper) { ChildTestUriMethods.new }

  let(:t_object) { TestObject.new("test", true) }
  let(:representer) { Api::TestObjectRepresenter.new(t_object) }

  it 'gets the path for url to represented' do
    representer.model_path(t_object).must_equal 'test_objects/1'
  end

  it 'helps an object become the represented base class' do
    class FooParent
    end
    class FooChild < FooParent
      def self.base_class
        FooParent
      end

      def becomes(_klass)
        'became'
      end
    end
    representer.becomes_represented_class(FooChild.new).must_equal 'became'
  end

  it 'creates a url to an alt web site' do
    representer.alternate_url('rainbows', 1).must_equal 'https://www.test.dev/rainbows/1'
  end

  it 'creates a uri for a model' do
    uri = "http://meta.test.dev/model/test-object"
    helper.model_uri('test_object').must_equal uri
    helper.model_uri(:test_object).must_equal uri
    helper.model_uri(TestObject).must_equal uri
    helper.model_uri(t_object).must_equal uri

    b = "http://meta.test.dev/model"
    helper.model_uri(Widget.new).must_equal "#{b}/widget"
    helper.model_uri(SpecialWidget.new).must_equal "#{b}/widget/special"
    helper.model_uri(VerySpecialThing.new).must_equal "#{b}/widget/very-special-thing"
  end

  it 'sets host uri attributes for parent' do
    alt_uri = "http://alt.meta.test.dev/model/test-object"
    alt_helper.model_uri('test_object').must_equal alt_uri
    child_helper.model_uri('test_object').must_equal alt_uri

    alt_b = "http://alt.meta.test.dev/model"
    alt_helper.model_uri(Widget.new).must_equal "#{alt_b}/widget"
    child_helper.model_uri(Widget.new).must_equal "#{alt_b}/widget"
  end

  it 'returns the meta host' do
    representer.profile_url.must_equal 'http://meta.test.dev/model/'
  end

  it 'returns the web host' do
    representer.alternate_url.must_equal 'https://www.test.dev/'
  end

  it 'uses path template for method missing' do
    representer.api_tests_path_template(title: '{title}').must_equal "/api/tests/{title}"
  end
end
