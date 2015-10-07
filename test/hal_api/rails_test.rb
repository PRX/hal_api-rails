require 'test_helper'

decribe HalApi::Rails do
  it 'has a version number' do
    ::HalApi::Rails::VERSION.wont_be_nil
  end
end
