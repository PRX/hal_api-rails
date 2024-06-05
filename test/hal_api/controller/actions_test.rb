require "test_helper"
require "test_models"
require "ostruct"

module ActiveRecord
  class RecordNotFound < StandardError
  end
end

describe HalApi::Controller::Actions do
  let(:controller) { FoosController.new }
  # stubbing out ActiveRecord dependant code
  # TODO: figure out how to make these test work without it
  #   or actually add in AR test models to test this.
  # let (:account) { create(:account) }

  describe "errors" do
    it "handles invalid content type errors" do
      controller.request = OpenStruct.new("content_type" => "nope")
      _(lambda do
        controller.create
      end).must_raise Mime::Type::InvalidMimeType
    end

    it "handles not found errors" do
      raises_exception = -> { raise ActiveRecord::RecordNotFound.new }
      controller.stub :resource, raises_exception do
        assert_raises(HalApi::Errors::NotFound) { controller.show }
      end
    end
  end

  describe "instance methods" do
    it "retrieves resource" do
      _(controller.send(:resource)).must_be_instance_of Foo
    end

    it "retrieves new resource when id not found" do
      controller.params = ActionController::Parameters.new(action: "create")
      controller.request = OpenStruct.new("put?" => false, "post?" => true, "content_type" => "application/json")
      _(controller.send(:resource)).must_be_instance_of Foo
      _(controller.send(:resource).id).must_be_nil
    end

    it "determines resource id for caching" do
      _(controller.send(:show_cache_path)).must_equal 60
    end

    it "determines the resources id for caching" do
      cache_key = "c/foos/1a8ca71da20c9dc2dfc2e02485821d9b"
      _(controller.send(:index_cache_path)).must_equal cache_key
    end

    it "responds to show request" do
      controller.show
      _(controller._respond_with).wont_be_nil
      _(controller._respond_with.first).must_be_instance_of Foo
      _(controller._respond_with.last[:_keys]).must_equal []
    end

    it "authorizes the resource" do
      _(controller).wont_be :respond_to?, :authorize, true
      assert controller.send(:hal_authorize, {})
      _(controller).must_be :respond_to?, :authorize, true
    end

    # it 'can add paging to resources query' do
    #   arel = FoosController.new.send(:paged, Account.where('id is not null'))
    #   _(arel.to_sql).must_match /LIMIT 10 OFFSET 0/
    # end
  end

  describe "class methods" do
    it "determines class for resource" do
      _(FoosController.resource_class).must_equal Foo
    end

    it "can specify filter params" do
      FoosController.filter_resources_by(:bar_id)
      _(FoosController.resources_params).must_equal [:bar_id]
    end

    it "can specify representer" do
      FoosController.represent_with(FooRepresenter)
      _(FoosController.resource_representer).must_equal FooRepresenter
    end

    it "specify allowed params for an action" do
      FoosController.allow_params :index, [:page, :per, :zoom]

      _(FoosController.valid_params).must_equal(index: [:page, :per, :zoom])
      _(FoosController.valid_params_list(:index)).must_equal([:page, :per, :zoom])

      class ChildFoosController < FoosController; end
      _(ChildFoosController.valid_params).must_equal(index: [:page, :per, :zoom])
      _(ChildFoosController.valid_params_list(:index)).must_equal([:page, :per, :zoom])
    end

    it "sets default cache options" do
      default_opts = {compress: true, expires_in: 1.hour, race_condition_ttl: 30}
      _(FoosController.cache_options).must_equal(default_opts)
    end

    it "caches api actions" do
      FoosController.cache_api_action(:index, bar: true)
      _(FoosController._caches_action[:index][:bar]).must_equal true
    end
  end
end
