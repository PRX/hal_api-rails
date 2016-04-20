# encoding: utf-8
require 'test_helper'
require 'test_models'

class TestUriMethods
  def self.alternate_host; "www.test.dev"; end

  def self.profile_host; "meta.test.dev"; end

  include HalApi::Representer::UriMethods
end

describe HalApi::Representer::UriMethods do

  let(:helper) { TestUriMethods.new }
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
