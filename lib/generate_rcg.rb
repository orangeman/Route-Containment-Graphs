require "rcg"
require "mfg"
require "benchmark"


# locs = MFG.locations
# locs.delete "Offenbach Main"
# locs.delete "Kehl Rhein"
# 
# routes = []
# locs.each do |o|
#   locs.each do |d|
#     routes << Route.new(o, d)
#   end
# end
# puts "generated routes #{Time.now}"
# 
# routes.each { |e| e.distance } 
# File.open("routes2.dump", "w") { |file| Marshal.dump(routes, file) }
# puts "calculated distances #{Time.now} "


# routes = Marshal.load File.open("routes2.dump")
# routes.each { |e|  if not e.distance; puts "#{e} deleted because no distance"; routes.delete e end} 
# Route.routes = routes
# rcg = RCG.new Route.all
# File.open("rcg_50lin_30th.dump", "w") { |file| Marshal.dump(rcg, file) }
# rcg.stats

