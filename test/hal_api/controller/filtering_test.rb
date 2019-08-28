require 'test_helper'

describe HalApi::Controller::Filtering do

  class FilteringTestController < ActionController::Base
    include HalApi::Controller::Filtering

    filter_params :one, :two, :three, :four, :five, six: :date, seven: :time

    attr_accessor :filter_string
    attr_accessor :no_facets

    def params
      { filters: filter_string }
    end

    def filter_facets
      {
        one: [{count: 2}],
        two: [],
        three: [
          {id: 'a', count: 4},
          {id: 'b', count: 5},
          {id: 'c', count: 0}
        ],
        four: [{count: 0}],
        five: [{id: 'a', count: 0}]
      } unless no_facets
    end
  end

  let(:controller) { FilteringTestController.new }

  it 'parses query params' do
    controller.filter_string = 'one,two=2,three=something,four='
    controller.filters.one.must_equal true
    controller.filters.two.must_equal 2
    controller.filters.three.must_equal 'something'
    controller.filters.four.must_equal ''
  end

  it 'restricts to known params' do
    controller.filter_string = 'one,foo,two,bar'
    controller.filters.one.must_equal true
    controller.filters.two.must_equal true
    err = assert_raises { controller.filters.foo }
    err.must_be_instance_of(HalApi::Errors::UnknownFilterError)
    err.hint.must_match /valid filters are: one two/i
    err = assert_raises { controller.filters.whatever }
    err.must_be_instance_of(HalApi::Errors::UnknownFilterError)
    err.hint.must_match /valid filters are: one two/i
  end

  it 'provides boolean testers' do
    controller.filter_string = 'one,two=1,three=false,four=,five=0'
    controller.filters.one?.must_equal true
    controller.filters.two?.must_equal true
    controller.filters.three?.must_equal false
    controller.filters.four?.must_equal true
    controller.filters.five?.must_equal true
    controller.filters.six?.must_equal false
    controller.filters.seven?.must_equal false
    assert_raises { controller.filters.whatever? }
  end

  it 'defaults to nil/false for unset filters' do
    controller.filter_string = nil
    controller.filters.one.must_be_nil
    controller.filters.one?.must_equal false
  end

  it 'parses dates' do
    controller.filter_string = 'six=20190203'
    controller.filters.six?.must_equal true
    controller.filters.six.must_equal Date.parse('2019-02-03')
  end

  it 'raises parse errors for dates' do
    controller.filter_string = 'six=bad-string'
    err = assert_raises { puts controller.filters.six }
    err.must_be_instance_of(HalApi::Errors::BadFilterValueError)
  end

  it 'parses datetimes' do
    controller.filter_string = 'seven=2019-02-03T01:02:03 -0700'
    controller.filters.seven?.must_equal true
    controller.filters.seven.must_equal Time.parse('2019-02-03T08:02:03Z')
  end

  it 'defaults datetimes to utc' do
    controller.filter_string = 'seven=20190203'
    controller.filters.seven?.must_equal true
    controller.filters.seven.must_equal Time.parse('2019-02-03T00:00:00Z')
  end

  it 'raises parse errors for times' do
    controller.filter_string = 'seven=bad-string'
    err = assert_raises { puts controller.filters.seven }
    err.must_be_instance_of(HalApi::Errors::BadFilterValueError)
  end

  it 'sets facets on the collection' do
    controller.index_collection.facets[:one].must_equal [{'count' => 2}]
    controller.index_collection.facets[:three].count.must_equal 2
    controller.index_collection.facets[:three][0].must_equal({'id' => 'a', 'count' => 4})
    controller.index_collection.facets[:three][1].must_equal({'id' => 'b', 'count' => 5})
  end

  it 'removes empty facets' do
    controller.index_collection.facets.keys.must_include 'one'
    controller.index_collection.facets.keys.must_include 'three'
    controller.index_collection.facets[:three].map { |f| f['id'] }.wont_include 'c'
    controller.index_collection.facets.keys.wont_include 'four'
    controller.index_collection.facets.keys.wont_include 'five'
    controller.index_collection.facets.keys.wont_include 'six'
  end

  it 'does not set facets if there are none' do
    controller.no_facets = true
    controller.index_collection.facets.must_be_nil
  end
end
