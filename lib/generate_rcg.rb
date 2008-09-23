require "rcg"
require "mfg"
require "benchmark"


# locs = MFG.locations
# locs.delete "Offenbach Main"
# locs.delete "Kehl Rhein"
# 
routes = []
# locs.each do |o|
#   locs.each do |d|
#     routes << Route.new(o, d)
#   end
# end
# File.open("routes2.dump", "w") { |file| Marshal.dump(routes, file) }




routes = Marshal.load File.open("routes.dump")
routes.each { |r| r.detours = {} } 



rcg = RCG.new routes
File.open("rcg.dump", "w") { |file| Marshal.dump(rcg, file) }
rcg.print