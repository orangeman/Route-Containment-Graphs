require "test/unit"
require "benchmark"

require "route"
require "mfg"

class TestRoute < Test::Unit::TestCase
  
  def test_add_remove_containees
    w = Route.new 'Nürnberg', 'Würzburg'
    f = Route.new 'Nürnberg', 'Frankfurt Main'
    f.add_containee w
    assert_equal(w, f.containees[0])
    assert_equal(f, w.containers[0])
    assert_equal(0, f.detour_via(w))
    k = Route.new 'Nürnberg', 'Kassel'
    k.add_containee f
    assert_equal(f, k.containees[0])
    assert_equal(k, f.containers[0])
    assert_equal(75, k.detour_via(f))
    k.remove_containee f
    assert_equal(0, k.containees.size)
    assert_equal(0, f.containers.size)
  end
end
