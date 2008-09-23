
require "net/http"
require "route"
require "cgi"


def escape(str)
  str.gsub!(/&(.+);/n) {
    case $1
      when 'auml'  then 'ä'
      when 'ouml'  then 'ö'
      when 'uuml'  then 'ü'
      when 'Auml'  then 'Ä'
      when 'Ouml'  then 'Ö'
      when 'Üuml'  then 'Ü'
      when 'szlig'  then 'ß'
    end
  }
  str.gsub! '.', ''
  str.gsub! '(', ''
  str.gsub! ')', ''
  str.gsub! '/ ', ' '
  str.gsub! '/', ' '
  str
end

html = Net::HTTP.get URI.parse('http://www.mitfahrgelegenheit.de')
orte = html.match(/(Alle Orte<option>)(.*)(<\/select>)/)[2].split '<option>'
orte.each do |e| escape e end
orte.each_with_index do |e, i| puts i.to_s+': '+e  end
  
def distance(orig, dest)
  begin
    kml = Net::HTTP.get URI.parse("http://maps.google.com/maps?output=kml&saddr=#{CGI.escape(orig+' germany')}&daddr=#{CGI.escape(dest+' germany')}")
    if match = kml.match(/(Distance: )([\d,]*)/)
      file = File.new(('kml/'+orig+'/'+orig+'2'+dest+'.kml').gsub(' ','_'), 'w')
      file.write kml
      file.close
      match[2].gsub ',', ''
    else
      nil
    end    
  rescue Exception => e
    puts "Exception occured: #{e}"
    distance(orig, dest)
  end
end

routes = []
errors = []

# f = File.new 'routes.dat', 'a'
orte.each_with_index do |orig, i|
  if File.exist?(('kml/'+orig).gsub(' ','_'))
    puts "guad :)"
  else 
    puts "AHA! da fehlt ja #{orig} !!!"
  end    
  # orte.each do |dest|
    # if orig != dest  
    #   if dist = distance(orig, dest)
    #     puts "von #{orig} nach #{dest} sind es #{dist} km"
    #     # routes << Route.new(orig, dest, dist)
    #   else  
    #     puts "von #{orig} nach #{dest} hamma nix :("
    #   end  
    # end  
  # end
  # Marshal.dump routes, f
  # f.flush
  # puts    
  # puts "Result #{i} for #{orig}: #{routes.size} routes"
  # puts "                    #{errors.size} errors"    
  # errors = []
  # routes = []
end    
# f.close
    
puts    
puts "---------------------------------------------"
puts "RESULT TOTAL: #{routes.size} routes"
puts "              #{errors.size} errors"    


