require 'test_helper'

class HalApi::RailsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::HalApi::Rails::VERSION
  end
end
