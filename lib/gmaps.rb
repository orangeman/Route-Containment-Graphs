require "net/http"
require "route"
require "cgi"


class GMaps
  
  @@kml_path = "../../kml/"
  
  def self.distance(from, to, save=false)
    return 0 if from == to
    # puts "entering gmaps.distance from #{from} to #{to}.."
    path = (@@kml_path+from+'/'+from+'2'+to+'.kml').gsub(' ','_')
  
    if File.exist? path
      kml = File.new(path, 'r').read
    else  
      kml = downloadKML from, to
      if save && (kml =~ /Distance: ([\d,]*)/)
        unless File.exist?((@@kml_path+from).gsub(' ','_'))
          Dir.mkdir((@@kml_path+from).gsub(' ','_'))
          puts "+ created directory: #{(@@kml_path+from).gsub(' ','_')}"
        end   
        file = File.new path, 'w'
        file.write kml
        file.close
        puts "  -> saved file '#{path}'"        
      end

    end
    
    begin
      # kml.match(/Distance: ([\d,]*)/)[1].gsub(',', '').to_i
      match = kml.match(/km \(about (\d*) hours? (\d*) mins?| (\d*) mins?\)/)
      match[1].to_i * 60 + match[2].to_i + match[3].to_i
    rescue Exception => e
      puts "No result for route #{from} -> #{to}"
      nil
    end
  end

  def self.downloadKML(from, to)
    puts "downloading kml #{from} -> #{to} .."
    begin  
      kml = Net::HTTP.get URI.parse("http://maps.google.com/maps?output=kml&saddr=#{CGI.escape(from)}&daddr=#{CGI.escape(to)}")
      if not kml =~ /Distance: ([\d,]*)/
        puts '  second try with appended "germany"..'
        kml = Net::HTTP.get URI.parse("http://maps.google.com/maps?output=kml&saddr=#{CGI.escape(from+' germany')}&daddr=#{CGI.escape(to+' germany')}")
      end  
    rescue Exception => e
      puts "Exception while downloading kml: #{e}"
      downloadKML(from, to)
    end
    kml
  end
  
end