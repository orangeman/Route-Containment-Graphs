require 'gmaps'

class Route
    
  def self.routes=(routes)
    @@lookUp = {}
    routes.each do |r|
      (@@lookUp[r.from] ||= {})[r.to] = r
    end
  end  
    
  def self.find(from=nil, to=nil)
    if to
      @@lookUp[from][to] ||= (if from == to; Route.new(from, to, 0) else Route.new(from, to, 999999) end)
    elsif from
      @@lookUp[from].values
    else
      @@routes
    end  
  end
  
  
  
  attr_accessor :from, :to, :distance, :detour, :detours
  attr_reader :containers, :containees
  
  def initialize(from, to, dist=nil)
    @from = from
    @to = to
    @distance = dist
    @containers = []
    @containees = []
    @detours = {}
  end
  
  def detour_via(route)
    @detours[route] || Route.find(from,route.from).dist + route.dist + Route.find(route.to,to).dist - dist
    # puts "calculated detour for #{self} via #{route}: #{@detours[route]} = #{find(from][route.from].dist} + #{route.dist} + #{find(route.to][to].dist} - #{distance}"
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
  
  def distance
    @distance ||= GMaps.distance(@from, @to, true)
  end
  
  def dist
    distance
  end

  def to_s
    "(#{@from[0..2]}->#{@to[0..2]}:#{detour})" 
    # "(#{@from[0..0]}<#{@distance}min>#{@to[0..0]})" 
  end

end