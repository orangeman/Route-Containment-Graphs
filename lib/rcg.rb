require "route"
require "pqueue"


class RCG
  $MAX_DETOUR = 50
  attr_accessor :routes, :lookUp
  
  def initialize(routes)
    @routes = routes
    @shortct_count = 0
    @removed_count = 0
    @revisit_count = 0
    @created_count = 0
    @routes.each do |route|
      puts "- processing #{route}"
      Route.lookUp(route.from).each do |bigger|
        next if route == bigger || bigger.dist == 0 || route.dist == 0
        det = bigger.detour_via(route)
        # if det*100/bigger.dist < $THRESHOLD
        if det < $MAX_DETOUR
          # puts "-> #{route} IS_CONTAINED_BY #{bigger}  DETOUR: #{det} (=#{route.dist}+#{Route.lookUp(route.to,bigger.to).dist}-#{bigger.dist})"
          @created_count += 1
          bigger.add_containee route
          route.containees.each do |smaller|  
            if smaller.containers.include? bigger
              # puts "    - und da gibts scho eins: #{smaller} is auch contained_by #{bigger} mit umweg #{bigger.detour_via smaller}"
              @revisit_count += 1
              if bigger.detour_via(smaller) < route.detour_via(smaller) + det - 30
                # puts "       des lass ma DRIN! weils ne Abkürzung ist: #{bigger.detour_via smaller} < #{route.detour_via smaller} + #{det} :)" 
                @shortct_count += 1
              else
                # puts "       des mach ma WEG! weils auf dem Weg liegt: #{bigger.detour_via smaller} > #{route.detour_via smaller} + #{det} :)" 
                @removed_count += 1
                bigger.remove_containee smaller
              end 
            end
          end  
        else
          # puts "-> #{route} too much detour #{bigger}  more than 30 % !!!"  
        end  
      end 
    end
  end
  def sort
    puts
    puts "sorting.."
    @routes.each do |route|
      route.containers.sort! { |a, b| a.detour_via(route) <=> b.detour_via(route) }
      route.containees.sort! { |a, b| route.detour_via(a) <=> route.detour_via(b) }
    end 
  end
  
  def print
    @routes.each do |route|
      puts "=> #{route}"
      route.containees.each do |c|  
        puts "    - VIA #{c}  DETOUR #{route.detour_via c}"
      end
    end  
    stats
  end
  
  def stats
    containment_count = 0
    detours_count = 0
    @routes.each do |route|
      containment_count += route.containers.size
      detours_count += route.detours.size
    end 
    puts 
    puts "============== STATS: ====================="
    puts "routes:               #{@routes.size}"
    puts "containments:         #{containment_count}"
    puts "cached detours:       #{detours_count}"
    puts "- - - - - - - - - - - - - - - - - - - - - -"
    puts "created containments: #{@created_count}"
    puts "revisit containments: #{@revisit_count}"
    puts "removed containments: #{@removed_count}"
    puts "discovered shortcuts: #{@shortct_count}"
    puts "==========================================="
    puts
    puts
  end
  
  
  def search(from, to)
    # puts "searching from #{from} to #{to}.."
    
    query = Route.lookUp(from, to)
    query.detour = 0

    pq = PQueue.new proc{ |x,y| 
      if x.detour != y.detour
        x.detour < y.detour
      # if x.detour_via(query) != y.detour_via(query)
      #         x.detour_via(query) < y.detour_via(query)
      elsif x.time_to_pickup(query) != y.time_to_pickup(query)
        x.time_to_pickup(query) < y.time_to_pickup(query)
      else  
        x.dist < y.dist
      end
    }  
    pq.push query
    res = []
    push_count = 0
    # while pq.size > 0
    pq.each_pop do |route|
      # route.detour = route.detour_via(query)
      res << route
      # puts "=> pop: #{route} with REAL detour #{route.detour_via query}"
      # puts "          => "+pq.to_a.to_s
      route.all_containers.each do |bigger|
        push_count += 1
        unless pq.qarray.include?(bigger) || res.include?(bigger)
          bigger.detour = bigger.detour_via query
          # puts "                 - push: #{bigger.from}->#{bigger.to}: #{bigger.detour} "
          pq.push bigger
        else  
          # puts "     (- push: #{bigger} with REAL detour #{bigger.detour_via query} (=#{route.detour}+#{bigger.detour_via route}))"
        end   
        # puts "         => "+pq.to_a.to_s      
      end  
    end
    # puts "search order: #{res}"
    # puts "pushes:  #{push_count}"
    # puts "results: #{res.size}"
    res
  end
  
  def generate_rcg
    
  end
  
  
end

# require "../test/tc_rcg"

