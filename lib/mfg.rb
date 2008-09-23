
require "net/http"
require "cgi"

class MFG
  
  def self.locations
    if File.exist? 'locations.dump'
      File.open('locations.dump') { |file| Marshal.load(file) }   
    else
      downloadLocations
    end
  end
  
  def self.downloadLocations
    html = Net::HTTP.get URI.parse('http://www.mitfahrgelegenheit.de')
    locs = html.match(/(Alle Orte<option>)(.*)(<\/select>)/)[2].split '<option>'
    locs.each do |l| escape l end
    
    # veryfy
    locs.each do |e| 
       unless GMaps.distance("Augsburg", e)
         unless e == "Augsburg"
           puts " deleted #{e} (not known by gmaps)"
           locs.delete e 
          end 
       end 
    end
    File.open("locations.dump", "w") { |file| Marshal.dump(locs, file) }
    locs
  end
  
  def self.escape(str)
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
    
    str.gsub! ' ad ', ' an der '
    str.gsub! ' id ', ' in der '
    str.gsub! /Allg(\s|)$/, 'Allgäu'
    str.gsub! 'Schwnd', 'Schwand'
    str.gsub! 'München Flughafen', 'Flughafen München Airport'
    str.gsub! 'Rothenburg Tauber', 'Rothenburg o d Tauber'
    str
  end
  
  def self.print
    locations.each_with_index do |e, i| puts i.to_s+': '+e end
    " COOL :)"
  end
  
end