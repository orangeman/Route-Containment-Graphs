require 'gmaps'

class Route
    
  def self.routes=(routes)
    
    print "sorting routes.. "
    @@routes = routes.sort { |x, y| x.distance <=> y.distance }
    puts "finished."
    
    @@lookUp = {}
    @@routes.each do |r|
      (@@lookUp[r.from] ||= {})[r.to] = r
    end
    @@routes.each do |r|
      r.reverse = @@lookUp[r.to][r.from]
      if r.reverse
        if r.reverse.reverse
          dist  = (r.distance + r.reverse.distance) / 2
          r.reverse.distance  = dist
          r.distance = dist
        end
      else
        @@routes.delete r
        puts "#{r} hat nix reverse :( getting removed both!"
      end  
    end 
  end 
  
  def self.all
    @@routes
  end
    
  def self.lookUp(from=nil, to=nil)
    if to
      @@lookUp[from][to] ||= (if from == to; Route.new(from, to, 0) else Route.new(from, to, 999999) end)
    else
      @@lookUp[from].values
    end  
  end
  
  
  
  attr_accessor :from, :to, :distance, :reverse, :detour, :detours
  attr_reader :containers, :containees
  
  def initialize(from, to, dist=nil)
    @from = from
    @to = to
    @distance = dist
    @containers = []
    @containees = []
    @detours = {}
  end
  
  def dist
    distance
  end

  def distance
    @distance ||= GMaps.distance(@from, @to, true)
  end

  def detour_via(route)
    @detours[route] || Route.lookUp(from,route.from).dist + route.dist + Route.lookUp(route.to,to).dist - dist
    # puts "calculated detour for #{self} via #{route}: #{@detours[route]} = #{lookUp(from][route.from].dist} + #{route.dist} + #{lookUp(route.to][to].dist} - #{distance}"
  end
  
  def time_to_pickup(route)
    Route.lookUp(from,route.from).dist
  end
  

  def add_containee(route)
    @detours[route] = detour_via(route)
    @containees << route
    route.containers << self
  end
  
  def remove_containee(route)
    @detours.delete route
    @containees.delete route
    route.containers.delete self
  end
  
  def all_containers
    containers + reverse.containers.map { |c| c.reverse }
  end
  
  def kml_path
    @kml_path ||= ('/routes/'+from+'/'+from+'2'+to+'.xml').gsub(' ','_')
  end
  
  def to_text
    "from: #{from}, germany to: #{to}, germany"
  end
  
  def to_s
    "(#{@from[0..2]}->#{@to[0..2]}: #{@detour})" 
  end

end