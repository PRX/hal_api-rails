# encoding: utf-8
require 'test_helper'
require 'hal_api/representer'
require 'hal_api/representer/link_serialize'

describe HalApi::Representer::LinkSerialize do

  it 'adds a property to set a linked resource' do

    class TestRepresenter < Roar::Decorator
      include Roar::JSON::HAL
      include HalApi::Representer::LinkSerialize

      link rel: :foo, writeable: true do
        { href: '/foo' }
      end
    end

    _(TestRepresenter.representable_attrs['set_foo_uri']).wont_be_nil
    _(TestRepresenter.representable_attrs['set_foo_uri'][:readable]).must_equal false
    _(TestRepresenter.representable_attrs['set_foo_uri'][:reader]).wont_be_nil
  end
end
