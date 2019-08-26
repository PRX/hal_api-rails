require 'test_helper'
require 'arel'

describe HalApi::Controller::Sorting do

  class SortingTestController < ActionController::Base
    include HalApi::Controller::Sorting

    sort_params default: { one: :desc }, allowed: [:one, :two, :three, :four, :camel_case]

    attr_accessor :sort_string

    def params
      { sorts: sort_string }
    end
  end

  let(:controller) { SortingTestController.new }

  before do
    controller.sort_string = 'one,two:asc,three:desc,four:,'
  end

  it 'sets a default array of sorts' do
    controller.class.default_sort.must_equal [{ one: :desc }]
  end

  it 'parses query params' do
    controller.sorts.count.must_equal 4
  end

  it 'defaults sorts to desc' do
    one = controller.sorts[0]
    one.keys.count.must_equal 1
    one.keys[0].must_equal 'one'
    one['one'].must_equal 'desc'
  end

  it 'can specify asc order' do
    two = controller.sorts[1]
    two.keys.count.must_equal 1
    two.keys[0].must_equal 'two'
    two['two'].must_equal 'asc'
  end

  it 'can specify desc order' do
    three = controller.sorts[2]
    three.keys.count.must_equal 1
    three.keys[0].must_equal 'three'
    three['three'].must_equal 'desc'
  end

  it 'defaults to desc if it ends with a semi-colon' do
    four = controller.sorts[3]
    four.keys.count.must_equal 1
    four.keys[0].must_equal 'four'
    four['four'].must_equal 'desc'
  end

  it 'throws an error on sorts that are not asc or desc' do
    controller.sort_string = 'one:blah'
    err = assert_raises { controller.sorts }
    err.must_be_instance_of(HalApi::Errors::BadSortError)
    err.message.must_match /invalid sort direction/i
    err.hint.must_match /valid directions are: asc desc/i
  end

  it 'throws an error on sorts that are not declared' do
    controller.sort_string = 'foobar'
    err = assert_raises { controller.sorts }
    err.must_be_instance_of(HalApi::Errors::BadSortError)
    err.message.must_match /invalid sort/i
    err.hint.must_match /valid sorts are: one two/i
  end

  it 'allows camel case sorts' do
    controller.sort_string = 'camel_case'
    controller.sorts[0].keys.must_equal ['camel_case']

    controller.sort_string = 'CamelCase'
    controller.sorts[0].keys.must_equal ['camel_case']

    controller.sort_string = 'camelCase'
    controller.sorts[0].keys.must_equal ['camel_case']
  end

  it 'sorted adds orders to resources arel' do
    sorts = [{ 'one' => 'desc' }, { 'two' => 'asc' }, { 'three' => 'desc' }, { 'four' => 'desc' }]
    table = Arel::Table.new(:api_test_sorting)
    result = controller.sorted(table)
    result.orders.must_equal sorts
  end

  it 'sorted adds default orders to resources arel' do
    controller.sort_string = nil
    sorts = [{ one: :desc }]
    table = Arel::Table.new(:api_test_sorting)
    result = controller.sorted(table)
    result.orders.must_equal sorts
  end

  it 'sets some default allowed sorts' do
    controller.allowed_sorts.must_equal %w(one two three four camel_case)
  end

  it 'sets filters on the collection' do
    controller.index_collection.sorts.must_equal %w(one two three four camel_case)
  end
end
