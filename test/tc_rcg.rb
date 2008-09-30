require "test/unit"
require "benchmark"

require "rcg"
require "gmaps"



class TestRcg < Test::Unit::TestCase  

  TESTS = 10_000
  
  # locs = 'München', 'Nürnberg', 'Ingolstadt', 'Erlangen', 'Frankfurt Main','Würzburg', 'Stuttgart', 'Augsburg'
  locs = 'Ulm', 'Hamburg', 'Berlin', 'München', 'Nürnberg', 'Würzburg', 'Ingolstadt', 'Erlangen', 'Frankfurt Main', 'Köln', 'Kassel', 'Paderborn', 'Hannover', 'Osnabrück', 'Oldenburg Oldb', 'Stuttgart', 'Augsburg'
  @@routes = []
  locs.each do |o|
    locs.each do |d|
      @@routes << Route.new(o, d)
    end
  end
  # 10.times { |n| routes.delete_at rand*routes.size }
  Route.routes = @@routes
  @@rcg = RCG.new Route.all
  # @@rcg.sort
  @@rcg.print

    
  def test_generate_rcg
    e = Route.lookUp 'Nürnberg', 'Erlangen'
    w = Route.lookUp 'Nürnberg', 'Würzburg'
    f = Route.lookUp 'Nürnberg', 'Frankfurt Main'
    k = Route.lookUp 'Nürnberg', 'Kassel'
    assert_equal true, w.containees.include?(e)
    assert_equal true, e.containers.include?(w)
    assert_equal true, f.containees.include?(w)
    assert_equal true, w.containers.include?(f)
    assert_equal false, f.containees.include?(e)
    assert_equal false, e.containers.include?(f)
    assert_equal(13, w.detour_via(e))
    assert_equal(15, f.detour_via(w))
    assert_equal(13, f.detour_via(e))
    assert_equal(73, k.detour_via(f))
    
    
    # Benchmark.bmbm do |results|
    #   puts
    #   results.report("detour lookup:") { TESTS.times do
    #     w.detour_via(e)
    #     f.detour_via(w)
    #   end }
    #   results.report("detour calc:  ") { TESTS.times do
    #     Route.lookUp(w.from,e.from).dist + e.dist + Route.lookUp(e.to,w.to).dist - w.dist
    #     Route.lookUp(f.from,w.from).dist + w.dist + Route.lookUp(w.to,f.to).dist - f.dist
    #   end }
    # end
    # puts
    # puts
    
    # @@routes = [f]
  end
  
  def test_search
    results_rcg = []
    results_brute_force = []
    Benchmark.bmbm do |results|
      results.report("RCG search:") do
        @@routes.each do |query|
          next if query.from == query.to
          results_rcg << @@rcg.search(query.from, query.to) if query.dist != 0
        end 
      end
      results.report("BruteForce search:") do
        @@routes.each do |query|
          next if query.from == query.to
          results_brute_force << brute_force_search(query) if query.dist != 0
        end
      end
    end
    puts
    results_rcg.each_with_index do |res_rcg, i|
      verify res_rcg, results_brute_force[i]
    end 
  end
  def verify(res_rcg, res_brute_force)
    #res_rcg.sort! { |a, b| a.detour <=> b.detour }
    # puts "JUHUU !!!!!!!!!!!!!  :)" if res_rcg == res_brute_force
    # puts "BÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄHHHH :(" else
    missing = []
    (res_brute_force.map { |e| e[0]}).each { |r|  missing << r if not res_rcg.include?(r)  } 
    # puts "REFERENCE: \n"+res_brute_force.to_s if not missing.empty?
    assert(missing.empty?, "There are route(s) missing: #{missing}")
    wrong = []
    res_rcg.each { |r| wrong << r if  !(res_brute_force.map {|e| e[0]}).include?(r) && r.detour_via(res_rcg[0]) < $MAX_DETOUR} 
    puts "REFERENCE: \n"+res_brute_force.to_s if not wrong.empty?
    assert(wrong.empty?, "There are wrong search results for #{res_rcg[0]}: #{wrong}")
  end
  
  def brute_force_search(query)
    res = []
    @@rcg.routes.each do |route|
      next if route.from == route.to
      det = route.detour_via query
      # res << [route, det] if det*100/route.dist < $THRESHOLD #&& route.from == query.from
      res << [route, det] if det < $MAX_DETOUR #&& route.from == query.from
    end 
    res.sort! { |a, b| if a[1]!=b[1]; a[1] <=> b[1] else a[0].dist <=> b[0].dist end}
    # res.map { |e| e[0]}
  end
end