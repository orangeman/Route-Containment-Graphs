require "test/unit"
require "benchmark"

require "gmaps"

class TestGmaps < Test::Unit::TestCase
  def test_distance
    assert_equal(219, GMaps.distance('Frankfurt Main', 'München'))
  end
end
