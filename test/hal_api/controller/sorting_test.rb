require "test_helper"
require "arel"

describe HalApi::Controller::Sorting do
  class SortingTestController < ActionController::Base
    include HalApi::Controller::Sorting

    sort_params default: {one: :desc}, allowed: [:one, :two, :three, :four, :camel_case]

    attr_accessor :sort_string

    def params
      {sorts: sort_string}
    end
  end

  let(:controller) { SortingTestController.new }

  before do
    controller.sort_string = "one,two:asc,three:desc,four:,"
  end

  it "sets a default array of sorts" do
    _(controller.class.default_sort).must_equal [{one: :desc}]
  end

  it "parses query params" do
    _(controller.sorts.count).must_equal 4
  end

  it "defaults sorts to desc" do
    one = controller.sorts[0]
    _(one.keys.count).must_equal 1
    _(one.keys[0]).must_equal "one"
    _(one["one"]).must_equal "desc"
  end

  it "can specify asc order" do
    two = controller.sorts[1]
    _(two.keys.count).must_equal 1
    _(two.keys[0]).must_equal "two"
    _(two["two"]).must_equal "asc"
  end

  it "can specify desc order" do
    three = controller.sorts[2]
    _(three.keys.count).must_equal 1
    _(three.keys[0]).must_equal "three"
    _(three["three"]).must_equal "desc"
  end

  it "defaults to desc if it ends with a semi-colon" do
    four = controller.sorts[3]
    _(four.keys.count).must_equal 1
    _(four.keys[0]).must_equal "four"
    _(four["four"]).must_equal "desc"
  end

  it "throws an error on sorts that are not asc or desc" do
    controller.sort_string = "one:blah"
    err = assert_raises { controller.sorts }
    _(err).must_be_instance_of(HalApi::Errors::BadSortError)
    _(err.message).must_match(/invalid sort direction/i)
    _(err.hint).must_match(/valid directions are: asc desc/i)
  end

  it "throws an error on sorts that are not declared" do
    controller.sort_string = "foobar"
    err = assert_raises { controller.sorts }
    _(err).must_be_instance_of(HalApi::Errors::BadSortError)
    _(err.message).must_match(/invalid sort/i)
    _(err.hint).must_match(/valid sorts are: one two/i)
  end

  it "allows camel case sorts" do
    controller.sort_string = "camel_case"
    _(controller.sorts[0].keys).must_equal ["camel_case"]

    controller.sort_string = "CamelCase"
    _(controller.sorts[0].keys).must_equal ["camel_case"]

    controller.sort_string = "camelCase"
    _(controller.sorts[0].keys).must_equal ["camel_case"]
  end

  it "sorted adds orders to resources arel" do
    sorts = [{"one" => "desc"}, {"two" => "asc"}, {"three" => "desc"}, {"four" => "desc"}]
    table = Arel::Table.new(:api_test_sorting)
    result = controller.sorted(table)
    _(result.orders).must_equal sorts
  end

  it "sorted adds default orders to resources arel" do
    controller.sort_string = nil
    sorts = [{one: :desc}]
    table = Arel::Table.new(:api_test_sorting)
    result = controller.sorted(table)
    _(result.orders).must_equal sorts
  end
end
