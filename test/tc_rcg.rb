require "test/unit"
require "benchmark"

require "rcg"
require "gmaps"



class TestRcg < Test::Unit::TestCase  

  TESTS = 10_000
  
  # locs = 'München', 'Nürnberg', 'Ingolstadt', 'Erlangen', 'Frankfurt Main','Würzburg', 'Stuttgart', 'Augsburg'
  locs = 'Berlin', 'München', 'Nürnberg', 'Würzburg', 'Ingolstadt', 'Erlangen', 'Frankfurt Main', 'Köln', 'Kassel', 'Paderborn', 'Hannover', 'Osnabrück', 'Oldenburg Oldb', 'Stuttgart', 'Augsburg'
  @@routes = []
  locs.each do |o|
    locs.each do |d|
      @@routes << Route.new(o, d)
    end
  end
  # 10.times { |n| routes.delete_at rand*routes.size }
  @@rcg = RCG.new @@routes
  @@rcg.print
    
  def test_generate_rcg
    e = Route.find 'Nürnberg', 'Erlangen'
    w = Route.find 'Nürnberg', 'Würzburg'
    f = Route.find 'Nürnberg', 'Frankfurt Main'
    k = Route.find 'Nürnberg', 'Kassel'
    assert_equal true, w.containees.include?(e)
    assert_equal true, e.containers.include?(w)
    assert_equal true, f.containees.include?(w)
    assert_equal true, w.containers.include?(f)
    assert_equal false, f.containees.include?(e)
    assert_equal false, e.containers.include?(f)
    assert_equal(12, w.detour_via(e))
    assert_equal(15, f.detour_via(w))
    assert_equal(13, f.detour_via(e))
    assert_equal(75, k.detour_via(f))
    
    # Benchmark.bmbm do |results|
    #   puts
    #   results.report("detour lookup:") { TESTS.times do
    #     w.detour_via(e)
    #     f.detour_via(w)
    #   end }
    #   results.report("detour calc:  ") { TESTS.times do
    #     Route.find(w.from,e.from).dist + e.dist + Route.find(e.to,w.to).dist - w.dist
    #     Route.find(f.from,w.from).dist + w.dist + Route.find(w.to,f.to).dist - f.dist
    #   end }
    # end
    # puts
    # puts
    
  end
  
  def test_search
    results_rcg = []
    results_brute_force = []
    Benchmark.bmbm do |results|
      results.report("RCG search:") do
        @@routes.each do |query|
          results_rcg << @@rcg.search(query.from, query.to) if query.dist != 0
        end 
      end
      results.report("BruteForce search:") do
        @@routes.each do |query|
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
    res_brute_force.each { |r|  missing << r if not res_rcg.include?(r)  } 
    assert(missing.empty?, "There are route(s) missing: #{missing}")
    wrong = []
    res_brute_force.each { |r| wrong << r if not res_brute_force.include?(r) } 
    assert(wrong.empty?, "There are wrong search results: #{wrong}")
  end
  
  def brute_force_search(query)
    res = []
    @@routes.each do |route|
      next if route.dist == 0
      det = route.detour_via query
      res << [route, det] if det*100/route.dist < 50 && route.from == query.from
    end 
    res.sort! { |a, b| if a[1]!=b[1]; a[1] <=> b[1] else a[0].dist <=> b[0].dist end}
    res.map { |e| e[0]}
  end
end