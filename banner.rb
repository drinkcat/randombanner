#!/usr/bin/ruby
# Nicolas Boichat -- February 2013
# http://drinkcat.blogspot.com/
# Public domain. Do whatever you want with it.
# I'd appreciate if you let me know if you use it, though.

months = ["January", "February", "March", "April", "May", "June",
	"July", "August", "September", "October", "November", "December"]

require 'yaml'
images = YAML.load_file('images.db')

# Sort by date. Conveniently, the date look like a float (e.g. 2012.12)
images.sort_by!{|image| image["date"]}

# Output Javascript file
f = File.open("jscode.js", "w")

# Open template
File.open("jscode.template").each{|line|
	# Replace line named **ARRAY** with array of banner, shift, and information
	if (line.chomp == "**ARRAY**") then
		ix = 0
		images.each{|image|
			puts image.inspect
			banner = image["url"].sub(/{}/, image["width"].to_s)
			shift = (image["repeat"])? "repeat" : "no-repeat"
			shift = shift + " center " + image["offset"].to_s + "px"
			info = image["text"];
			f.puts "banner[#{ix}]=\"#{banner}\""
			f.puts "shift[#{ix}]=\"#{shift}\"\n"
			f.puts "information[#{ix}]=\"#{info}\"\n"
			ix = ix + 1
		}
		f.puts imagecode
	else
		# Copy all other lines
		f.print line
	end
}

f.close

# Output HTML file
f = File.open("pagecode.html", "w")

images.each{|image|
	puts image.inspect
	fullsize = image["url"].sub(/{}/, 0.to_s)
	previewsize = image["url"].sub(/{}/, 640.to_s)
	info = image["text"] + " - " + months[(image["date"] % 1 * 100).round-1] + " " + image["date"].floor.to_s;

	# Open template for each image, and replace strings
	File.open("pagecode.html.template").each{|line|
		line = line.sub(/##FULLSIZE##/, fullsize)
		line = line.sub(/##640SIZE##/, previewsize)
		line = line.sub(/##INFO##/, info)
		f.print line
	}
}

f.close

