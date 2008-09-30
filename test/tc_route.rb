require "test/unit"
require "benchmark"

require "route"
require "mfg"

class TestRoute < Test::Unit::TestCase
  
    @@nw = Route.new 'Nürnberg', 'Würzburg'
    @@nf = Route.new 'Nürnberg', 'Frankfurt Main'
    @@nk = Route.new 'Nürnberg', 'Kassel'
    @@wf = Route.new 'Würzburg', 'Frankfurt Main'
    @@fk = Route.new 'Frankfurt Main', 'Kassel'
    @@fw = Route.new 'Frankfurt Main', 'Würzburg'
    @@wn = Route.new 'Würzburg', 'Nürnberg'
    @@fn = Route.new 'Frankfurt Main', 'Nürnberg'
    @@kn = Route.new 'Kassel', 'Nürnberg'
    @@nw.reverse = @@wn; @@wn.reverse = @@nw
    @@nf.reverse = @@fn; @@fn.reverse = @@nf
    @@nk.reverse = @@kn; @@kn.reverse = @@nk
    @@fw.reverse = @@wf; @@wf.reverse = @@fw
    Route.routes = [@@nw,@@nf,@@nk,@@wf,@@fw,@@fk,@@wn,@@fn,@@kn]      
  
  def test_add_containee  
    @@nf.add_containee @@nw
    assert_equal(@@nw, @@nf.containees[0])
    assert_equal(@@nf, @@nw.containers[0])
    assert_equal(15, @@nf.detour_via(@@nw))
    assert_equal(0, @@nf.time_to_pickup(@@nw))
    assert_equal(76, @@fn.time_to_pickup(@@wn))
    @@nk.add_containee @@nf
    @@nk.add_containee @@nw
    assert_equal(@@nf, @@nk.containees[0])
    assert_equal(@@nk, @@nf.containers[0])
    assert_equal(75, @@nk.detour_via(@@nf))
  end
  
  def test_all_containers    
    assert_equal(@@fn, @@wn.all_containers[0])
    assert_equal(@@kn, @@wn.all_containers[1])
    puts
    puts @@wn.all_containers
  end

  def test_remove_containee
    @@nk.remove_containee @@nf
    assert_equal(1, @@nk.containees.size)    
    assert_equal(0, @@nf.containers.size)
    @@nk.remove_containee @@nw
    @@nf.remove_containee @@nw
    assert_equal(0, @@nk.containees.size)    
    assert_equal(0, @@nw.containers.size)    
  end
  
end
