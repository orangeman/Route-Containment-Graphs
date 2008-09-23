

# MFG.locations.each do |l|
#   gibts = false
#   Dir.new('kml').each do |d| gibts = d if CGI.escape(l.gsub(' ', '_')) == CGI.escape(d.to_s) end
#   p "habIDi! saparalot! #{CGI.escape(l.gsub(' ', '_'))} gibts nicht!" unless gibts
# end

Dir.new('../kml').each do |d|
  if File.directory?('../kml/'+d) && Dir.new('../kml/'+d).entries.size <= 484
    puts "AHA: #{d} hat nur #{Dir.new('../kml/'+d).entries.size} routen!"
    # puts Dir.delete('kml/'+d)
  end
end

# File.open("routes.dump") { |file| 
#   routes = Marshal.load(file)
#   k = 0
#   routes.each do |e| 
#      k += e.distance
#   end
#   puts k
# }

# Dir.new('kml').entries[3..5].each do |d| 
#   dd = Dir.new('kml/'+d)
#   dd.entries.each do |e| 
#      if File.size(dd.path+'/'+e) == 0
#        PUTS 'AHA'
#        # File.delete(dd.path+'/'+e)
#     end   
#   end
  

# puts MFG.locations.size
# 
# 
# routes = []
# errors = []
# MFG.locations.each do |from|
#   puts
#   puts "processing #{from}..."
#   MFG.locations.each do |to|
#     if from != to
#       r = Route.new from, to 
#       if r.distance
#         routes << r
#       else 
#         errors << r
#       end  
#     end
#   end 
# end
# 
# puts "________________________"
# puts "routes: "+routes.size.to_s
# puts "errors: "+errors.size.to_s
# File.open("routes.dump", "w") { |file| Marshal.dump(routes, file) }
# File.open("errors.dump", "w") { |file| Marshal.dump(errors, file) }








# class Route
#   attr_accessor :origin, :destination, :distance
# end
# 
# f = File.new 'routes.dat', 'r'
# routes = []
# count = 0
# 
# 493.times do
#   begin
#     routes += Marshal.load f
#     count += 1    
#     # puts 'gelesen'
#   rescue Exception => e
#     puts 'aha: '+e
#     break
#   end
# end  
# 
# 
# puts '---------------------------------------------------------'
# puts 'TOTAL: ' + routes.size.to_s + ' routes (so far;)'
# puts '  FOR: ' + count.to_s+' locations :)'
#   
#   
  