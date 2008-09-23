require "route"
require "gmaps"


routes = Marshal.load File.open("routes.dump")
@lookUp = {}
routes.each do |r|
  (@lookUp[r.from] ||= {})[r.to] = r
end

routes.each { |r|
  print "processing #{r}.."
  Dir.mkdir "rcg/#{r.from}" unless File.exist? "rcg/#{r.from}"
  routes.each { |c| 
    if @lookUp[c.from][r.from] && @lookUp[r.to][c.to]
     det = @lookUp[c.from][r.from].dist + r.dist + @lookUp[r.to][c.to].dist - c.dist
     if det*100/c.dist < 15
       r.containers << [c, det]
     end
    end 
  }
  r.containers.sort! {|x,y| x[1] <=> y[1]}
  File.open("rcg/#{r.from}/#{r}.dump", "w") { |file| Marshal.dump(r, file) }
  puts "#{r.containers.size} containments!"
}

