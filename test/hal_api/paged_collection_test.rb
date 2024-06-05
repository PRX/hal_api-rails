require "test_helper"
require "hal_api/paged_collection"
require "test_models"
require "kaminari"
require "kaminari/models/array_extension"
require "ostruct"

describe HalApi::PagedCollection do
  let(:items) { (0..25).collect { |t| TestObject.new("test #{t}", true) } }
  let(:paged_items) { Kaminari.paginate_array(items).page(1).per(10) }
  let(:paged_collection) { HalApi::PagedCollection.new(paged_items, OpenStruct.new(params: {})) }

  it "creates a paged collection" do
    _(paged_collection).wont_be_nil
    _(paged_collection.items).wont_be_nil
    _(paged_collection.request).wont_be_nil
  end

  it "has delegated methods" do
    _(paged_collection.request.params).must_equal({})
    _(paged_collection.params).must_equal({})

    _(paged_collection.items.count).must_equal 10
    _(paged_collection.count).must_equal 10
    _(paged_collection.items.total_count).must_equal 26
    _(paged_collection.total).must_equal 26
  end

  it "implements to_model" do
    paged_collection = HalApi::PagedCollection.new([])
    _(paged_collection.to_model).must_equal paged_collection
  end

  it "is never persisted" do
    paged_collection = HalApi::PagedCollection.new([])
    _(paged_collection).wont_be :persisted?
  end

  it "has a stubbed request by default" do
    paged_collection = HalApi::PagedCollection.new([])
    _(paged_collection.params).must_equal({})
  end

  it "will be a root resource be default" do
    _(paged_collection.is_root_resource).must_equal true
  end

  it "will be a root resource based on options" do
    paged_collection.options[:is_root_resource] = false
    _(paged_collection.is_root_resource).must_equal false
  end

  it "has an item_class" do
    _(paged_collection.item_class).must_equal(TestObject)
  end

  it "has an item_decorator" do
    _(paged_collection.item_decorator).must_equal(Api::TestObjectRepresenter)
  end

  it "has an url" do
    paged_collection.options[:url] = "test"
    _(paged_collection.url).must_equal "test"
  end

  it "has a parent" do
    class TestFoo
      def self.columns
        @columns ||= []
      end
    end

    class TestBar < TestFoo
      def becomes(klass)
        klass.new
      end

      def self.base_class
        TestFoo
      end
    end

    a = TestBar.new
    _(a).wont_be_instance_of TestFoo
    paged_collection.options[:parent] = a
    _(paged_collection.parent).must_be_instance_of TestFoo
  end
end
