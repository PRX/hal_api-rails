# encoding: utf-8
require 'test_helper'
require 'hal_api/representer'
require 'hal_api/representer/link_serialize'

describe HalApi::Representer::LinkSerialize do

  it 'sets a default curie' do

    class TestRepresenter < Roar::Decorator
      include Roar::JSON::HAL
      include HalApi::Representer::LinkSerialize

      link rel: :foo, writeable: true do
        { href: '/foo' }
      end
    end

    TestRepresenter.representable_attrs[:definitions]['set_foo_uri'].wont_be_nil
    TestRepresenter.representable_attrs[:definitions]['set_foo_uri'][:readable].must_equal false
    TestRepresenter.representable_attrs[:definitions]['set_foo_uri'][:reader].wont_be_nil
  end
end