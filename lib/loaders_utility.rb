module LoadersUtility
  
  class ContentLoader
  
  	@abbrErr = "LOD"
  
  	# Get the Date & Time object of server
  	def self.get_time
  		Time.now
  	end
  	
  	# This method is used for loading customized items with placeholder
  	# Input data should have form like [{"key1" => "val1", "key2" => "val2"}, ...]
  	# Output data is either an exception or a string
  	def self.load_items_with_placeholder(plhName, data)
  		tResult = ''
  		
  		plh = Metadata.find(:first, :conditions => ["key = :key and cat = :cat", {
	  		:key => plhName.strip,
	  		:cat => 'placeholder'
  		}])
  		
  		if (!plh.nil?)
  		
  			data.each do |t|
  				plhTpl = plh.value.strip
  				
  				parsedObjs = plhTpl.scan(/\[\[\$[a-zA-Z\-]+\]\]/)
  				
  				parsedObjs.each do |o|
  					oraw = o.gsub(/[^a-zA-Z\-]/,'')
  					plhTpl = plhTpl.gsub(o, t[oraw]) 
  				end
  				
  				tResult << plhTpl
  			end
  			
  			tResult
  		else
  			raise "ContentLoader - #{@abbrErr}001 - The placeholder \"#{plhName}\" doesn't exist"
  		end	
  	end
  	
  end
  
end