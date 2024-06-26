# encoding: utf-8
require 'test_helper'
require 'test_models'
require 'ostruct'

class TestEmbedsRenderPipeline
  attr_accessor :represented
  include HalApi::Representer::Embeds::HalApiRailsRenderPipeline
end

EmbedsTest = Struct.new(:title)

describe HalApi::Representer::Embeds do
  let(:helper) { class TestUriMethods; include Embeds; end.new }
  let(:t_object) { TestObject.new("test", true) }
  let(:mapper) { TestEmbedsRenderPipeline.new.tap { |m| m.represented = t_object } }
  let(:prop_name) { 'prop_name' }
  let(:repr_binding) do
    p = prop_name
    Struct.
      new(:as, :embedded, :zoom).
      new(TestOption.new('t:test'), true, nil).
      tap do |b|
        b.define_singleton_method(:evaluate_option) { |*| p }
      end
  end

  describe "non embedded property" do
    let (:non_embed_binding) { repr_binding.tap{|b| b.embedded = false } }

    it "is never suppressed" do
      _(mapper.suppress_embed?(non_embed_binding, {options: {}, binding: repr_binding})).must_equal false
    end
  end

  describe "default zoom" do
    let (:default_binding) { repr_binding.tap{|b| b.zoom = nil } }

    it "is not suppressed by default" do
      _(mapper.suppress_embed?(default_binding, {options: {}, binding: repr_binding})).must_equal false
    end

    it "is suppressed when specifically unrequested" do
      options = {user_options: {zoom: ['t:none']}}
      _(mapper.suppress_embed?(default_binding, {options: options, binding: repr_binding} )).must_equal true
    end
  end

  describe "zoom: true" do
    let (:true_binding) { repr_binding.tap{|b| b.zoom = true } }
    let (:prop_name) { 't:test'}

    it "is not suppressed by default" do
      _(mapper.suppress_embed?(true_binding, {options: {}, binding: repr_binding})).must_equal false
    end

    it "is suppressed when specifically unrequested" do
      options = {user_options: {zoom: ['t:none']}}
      _(mapper.suppress_embed?(true_binding, {options: options, binding: repr_binding})).must_equal true
    end

    it "is unsuppressed when requested" do
      options = {user_options: {zoom: ['t:test']}}
      _(mapper.suppress_embed?(true_binding, {options: options, binding: repr_binding})).must_equal false
    end
  end

  describe "zoom: always" do
    let (:always_binding) { repr_binding.tap{|b| b.zoom = :always } }

    it "is not suppressed when specifically unrequested" do
      options = {user_options: {zoom: ['t:test']}}
      _(mapper.suppress_embed?(always_binding, {options: options, binding: repr_binding})).must_equal false
    end
  end

  describe "zoom: false" do
    let (:false_binding) { repr_binding.tap{|b| b.zoom = false } }

    it "is suppressed by default" do
      _(mapper.suppress_embed?(false_binding, {options: {}, binding: repr_binding})).must_equal true
    end
  end

  it "defines an embed to set a representable property" do

    class Embeds1TestRepresenter < Api::BaseRepresenter
      embed :test_object, class: TestObject, zoom: :always
    end

    embed_definition = Embeds1TestRepresenter.representable_attrs['test_object']
    _(embed_definition).wont_be_nil
    _(embed_definition[:embedded]).must_equal true
    _(embed_definition[:class].call).must_equal TestObject
    _(embed_definition[:zoom]).must_equal :always
  end

  it "defines an embed to set a representable property" do

    class Embeds2TestRepresenter < Api::BaseRepresenter
      embeds :test_objects, class: TestObject, zoom: :always
    end

    embed_definition = Embeds2TestRepresenter.representable_attrs['test_objects']
    _(embed_definition).wont_be_nil
    _(embed_definition[:embedded]).must_equal true
    _(embed_definition[:class].call).must_equal TestObject
    _(embed_definition[:zoom]).must_equal :always
  end

  it 'does not interfere with non-halapi representers' do
    class ThingRepresenter < Representable::Decorator
      include Representable::JSON
      include HalApi::Representer::Embeds
      property :foo
    end

    class Thing < OpenStruct; end

    thing = Thing.new(foo: 'bar', any: 'thing')
    _(ThingRepresenter.new(thing).to_json).must_equal '{"foo":"bar"}'
  end
end
