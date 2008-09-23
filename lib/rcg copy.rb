require "route"
require "pqueue"
require "benchmark"

class RCG
  
  attr_accessor :routes, :lookUp
  
  def initialize(routes)
    @routes = routes.sort! do |x, y| x.distance <=> y.distance end
    abk_count = 0
    @routes.each do |route| 
      Route.find(route.from).each do |bigger|  
        next if route == bigger || bigger.dist == 0 || route.dist == 0
        det = bigger.detour_via(route)
        if det*100/bigger.dist < 50
          puts "-> #{route} IS_CONTAINED_BY #{bigger}  DETOUR: #{det} (=#{route.dist}+#{Route.find(route.to,bigger.to).dist}-#{bigger.dist})"
          bigger.add_containee route
          route.containees.each do |smaller|  
            if smaller.containers.include? bigger
              puts "    - und da gibts scho eins: #{smaller} is auch contained_by #{bigger} mit umweg #{bigger.detour_via smaller}"
              if bigger.detour_via(smaller) < route.detour_via(smaller) + det - 30
                puts "       des lass ma DRIN! weils ne Abkürzung ist: #{bigger.detour_via smaller} < #{route.detour_via smaller} + #{det} :)" 
                abk_count += 1
              else
                puts "       des mach ma WEG! weils auf dem Weg liegt: #{bigger.detour_via smaller} > #{route.detour_via smaller} + #{det} :)" 
                bigger.remove_containee smaller
              end 
            end
          end  
        else
          puts "-> #{route} too much detour #{bigger}  more than 30 % !!!"  
        end  
      end  
    end
    containment_count = 0
    detours_count = 0
    @routes.each do |route|
      containment_count += route.containers.size
      detours_count += route.detours.size
    end  
    puts "================ STATISTICS =============="
    puts "routes:         #{@routes.size}"
    puts "containments:   #{containment_count}"
    puts "cached detours: #{detours_count}"
    puts "abkürzungen:    #{abk_count}"
  end
  
  def print
    @routes.each do |r|
      r.containees.each do |c|  
        puts c.to_s + ' VIA ' + Route.find(c.containee.to, c.container.to).to_s
      end
    end
  end
  
  def search(from, to)
    puts
    puts "==============================="
    puts "searching from #{from} to #{to}.."
    
    query = Route.find(from, to)
    query.detour = 0

    pq = PQueue.new proc{ |x,y| 
      # if x.detour != y.detour
      #   x.detour < y.detour
      if x.detour_via(query) != y.detour_via(query)
              x.detour_via(query) < y.detour_via(query)
      # elsif x.time_to_pickup(query) != y.time_to_pickup(query)
      #   x.time_to_pickup(query) < y.time_to_pickup(query)
      else  
        x.dist < y.dist
      end
    }  
    pq.push query
    res = []
    
    # while pq.size > 0
    pq.each_pop do |route|
      res << route
      puts "=> pop: #{route} with REAL detour #{route.detour_via query}"
      # puts "          => "+pq.to_a.to_s
      route.containers.each do |bigger|
        det = route.detour + bigger.detour_via(route)
        puts "      - push: #{bigger} with REAL detour #{bigger.detour_via query} (=#{route.detour}+#{bigger.detour_via route})"
        if pq.qarray.include?(bigger) || res.include?(bigger)
          if det < bigger.detour
            puts "        ABKÜRZUNG !!!"
            puts "!!!!!!!!!!!!!!!!!!!!!!!!! DARF NICHT SEIN !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" if res.include? bigger
            bigger.detour = det
            pq.make_legal
          end  
        else 
          bigger.detour = det
          pq.push bigger
        end   
        # puts "         => "+pq.to_a.to_s      
      end  
    end
    
    puts "___________________________________"
    puts "search order: #{res}"
    res
  end
  
  
end





