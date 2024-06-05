require "test_helper"
require "hal_api/paged_collection"
require "hal_api/paged_collection_representer"
require "test_models"
require "ostruct"

describe HalApi::PagedCollectionRepresenter do
  let(:items) { (0..25).collect { |t| TestObject.new("test #{t}", true) } }
  let(:paged) { Kaminari.paginate_array(items).page(1).per(10) }
  let(:request) do
    OpenStruct.new(params: {
      "page" => "1",
      "action" => "index",
      "api_version" => "v1",
      "controller" => "api/test_objects",
      "format" => "json"
    })
  end

  let(:paged_collection) { HalApi::PagedCollection.new(paged, request, is_root_resource: true) }
  let(:representer) { HalApi::PagedCollectionRepresenter.new(paged_collection) }
  let(:json) { JSON.parse(representer.to_json) }

  it "creates a paged collection representer" do
    _(representer).wont_be_nil
  end

  it "has a represented_url" do
    representer.represented.options[:url] = "api_stories_path"
    _(representer.represented_url).must_equal "api_stories_path"
  end

  it "has a vary link" do
    representer.represented.options[:url] = "api_stories_path"
    _(json["_links"]["vary"]).wont_be_nil
    _(json["_links"]["vary"]["href"]).must_equal "api_stories_path{?page,per,zoom,filters,sorts}"
    _(json["_links"]["vary"]["templated"]).must_equal true
  end

  it "uses a lambda for a url method" do
    representer.represented.options[:url] = ->(options) { options.keys.sort.join("/") }
    _(representer.href_url_helper({foo: 1, bar: 2, camp: 3})).must_equal "bar/camp/foo"
  end

  it "uses a lambda for a url method, references represented parent" do
    representer.represented.options[:parent] = "this is a test"
    representer.represented.options[:url] = ->(options) { represented.parent }
    _(representer.href_url_helper({foo: 1, bar: 2, camp: 3})).must_equal "this is a test"
  end

  describe "requires routes" do
    before { define_routes }

    after { Rails.application.reload_routes! }

    it "paged collection contains tests _links" do
      _(json["_embedded"]["items"]).wont_be_nil
      _(json["_embedded"]["items"].size).must_equal 10
    end

    it "gets a route url helper method" do
      representer.represented.options[:url] = "api_test_objects_path"
      _(representer.represented_url).must_equal "api_test_objects_path"
      _(representer.href_url_helper({page: 1})).must_equal "/api/test_objects?page=1"
    end

    it "gets a route url helper method with parent" do
      representer.represented.options[:parent] = TestParent.new(1, true)
      representer.represented.options[:item_class] = TestObject

      nested_page = "/api/test_parents/1/test_objects?page=1"
      _(representer.href_url_helper(page: 1)).must_equal nested_page
    end
  end
end
