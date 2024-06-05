require "test_helper"
require "test_models"
require "action_controller"
require "ostruct"

describe HalApi::Controller do
  let(:controller) { FoosController.new }

  describe "errors" do
    it "handles invalid content type errors" do
      controller.request = OpenStruct.new("content_type" => "nope")
      _(lambda do
        controller.create
      end).must_raise Mime::Type::InvalidMimeType
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
      assert controller.send(:hal_authorize, {})
      assert controller.send(:authorize, {})
    end

    describe "#show_cache_path" do
      let(:some_foo) { Foo.find }

      it "returns a path based on an updated_at timestamp" do
        _(controller.send(:show_cache_path)).must_equal 60
      end

      it "returns a path based on created_at if updated_at is nil" do
        some_foo.updated_at = nil
        some_foo.created_at = DateTime.parse("1970-01-01 00:00:30")
        controller.stub(:resource, some_foo) do
          _(controller.send(:show_cache_path)).must_equal 30
        end
      end
      it "uses the current time if update_at and created_at are nil" do
        some_foo.updated_at = nil
        some_foo.created_at = nil
        controller.stub(:resource, some_foo) do
          controller.stub(:current_time, DateTime.parse("1970-01-01 00:05:33")) do
            _(controller.send(:show_cache_path)).must_equal 333
          end
        end
      end
    end
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
