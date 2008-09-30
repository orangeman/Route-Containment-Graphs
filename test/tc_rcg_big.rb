require "test/unit"
require "benchmark"

require "rcg"
require "gmaps"



class TestRcg < Test::Unit::TestCase  

  @@rcg = Marshal.load File.open("rcg_50proz_30th.dump")
  Route.routes = @@rcg.routes
  @@rcg.stats
    
  def test_generate_rcg
    # e = Route.find 'Nürnberg', 'Erlangen'
    # w = Route.find 'Nürnberg', 'Würzburg'
    # f = Route.find 'Nürnberg', 'Frankfurt Main'
    # k = Route.find 'Nürnberg', 'Kassel'
    # assert_equal true, w.containees.include?(e)
    # assert_equal true, e.containers.include?(w)
    # assert_equal true, f.containees.include?(w)
    # assert_equal true, w.containers.include?(f)
    # assert_equal false, f.containees.include?(e)
    # assert_equal false, e.containers.include?(f)
    # assert_equal(12, w.detour_via(e))
    # assert_equal(15, f.detour_via(w))
    # assert_equal(13, f.detour_via(e))
    # assert_equal(75, k.detour_via(f))
    
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
    # results_rcg = []
    # results_brute_force = []
    res_rcg, res_brute_force = nil
    Benchmark.bmbm do |results|
      results.report("RCG search:") do
        res_rcg = @@rcg.search 'Nürnberg', 'Erlangen'
        # @@routes.each do |query|
          # results_rcg << @@rcg.search(query.from, query.to) if query.dist != 0
        # end 
      end
      results.report("BruteForce search:") do
        res_brute_force = brute_force_search Route.find('Nürnberg', 'Erlangen')
        # @@routes.each do |query|
        #   results_brute_force << brute_force_search(query) if query.dist != 0
        # end
      end
    end
    puts
    verify res_rcg, res_brute_force
    # results_rcg.each_with_index do |res_rcg, i|
    #   verify res_rcg, results_brute_force[i]
    # end 
  end
  
  def verify(res_rcg, res_brute_force)
    #res_rcg.sort! { |a, b| a.detour <=> b.detour }
    # puts "JUHUU !!!!!!!!!!!!!  :)" if res_rcg == res_brute_force
    # puts "BÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄHHHH :(" else
    missing = []
    res_brute_force.each { |r|  missing << r if not res_rcg.include?(r)  } 
    assert(missing.empty?, "There are route(s) missing: #{missing}")
    wrong = []
    res_rcg.each { |r| wrong << r if not res_brute_force.include?(r) } 
    assert(wrong.empty?, "There are wrong search results: #{wrong}")
  end
  
  def brute_force_search(query)
    res = []
    @@rcg.routes.each do |route|
      next if route.dist == 0
      det = route.detour_via query
      res << [route, det] if det*100/route.dist < $THRESHOLD && route.from == query.from
      # res << [route, det] if det < $THRESHOLD && route.from == query.from
    end 
    res.sort! { |a, b| if a[1]!=b[1]; a[1] <=> b[1] else a[0].dist <=> b[0].dist end}
    res.map { |e| e[0]}
  end
end