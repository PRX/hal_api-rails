# encoding: utf-8
require 'test_helper'

describe HalApi::Representer::Curies do
  it 'sets a default curie' do

    class Test1Representer < Roar::Decorator
      include Roar::JSON::HAL
      include HalApi::Representer::Curies

      use_curie(:test)
    end

    Test1Representer.default_curie.must_equal :test
  end

  it 'defines curie links' do
    class Test2Representer < Roar::Decorator
      include Roar::JSON::HAL
      include HalApi::Representer::Curies

      curies(:test) do
        [{ name: :test, href: "http://meta.test.com/relation/{rel}", templated: true }]
      end
    end

    repr = Test2Representer.new(Object.new)

    # initialize internal state
    repr.as_json

    repr_attrs = repr.instance_variable_get(:@representable_attrs)
    links_obj = repr_attrs["links"]

    links_obj.link_configs.size.must_equal 1
    links_obj.link_configs.first.first[:rel].must_equal :curies
  end
end
