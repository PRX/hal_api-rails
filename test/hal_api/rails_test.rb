require "test_helper"

describe HalApi::Rails do
  it "has a version number" do
    _(::HalApi::Rails::VERSION).wont_be_nil
  end
end
