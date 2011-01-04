# This script generates thumbnails of all the images of a specified directory
# it will place all the resized images on the given directory, in case missing they will be placed on %images_dir%/output
# Author: José Fernández Alameda
# Email: jose (at) alamedanet.es
#
#
# Command line arguments
#
# Arguments
# -i /path/to/images -> Indicates the directory where the images we want to transform are
# -o /path/to/output -> Folder where the output generated images will be placed
# -v Verbose mode
# -w Display warnings
# -s NUMBER -> Size of the ouput image in pixels
# E.g.
#      
#       $ ruby thumbnails_generator.rb -i images -o thumbnails -v -w -s 150
#

#Image handling libraries

require 'rubygems'
require 'RMagick'
include Magick

$options = {
  "DISPLAY_WARNINGS" => false,
  "OUTPUT_DIR"       => nil,
  "IMAGES_DIR"       => nil,
  "SIZE"             => 150,
  "VERBOSE_MODE"     => false
}

def parse_command_line_options(args)
  
  abbr = {
    "-o" => "OUTPUT_DIR",
    "-i" => "IMAGES_DIR",
    "-s" => "SIZE",
    "-w" => "DISPLAY_WARNINGS",
    "-v" => "VERBOSE_MODE"
  }
  
  option_index = 0
  
  args.each do |key|
    if(args.index(key) != nil) then
      if(key == "-w" || key == "-v") then
        $options[abbr[key]] = true
      else
        $options[abbr[key]] = args[option_index+1]
      end
      option_index += 1
    end
  end
  
end

def __v(msg)
  if($verbose) then
    puts msg
  end
end

#Getting the images directory from the command-line arguments
parse_command_line_options(ARGV)

images_dir  = $options["IMAGES_DIR"]
output_dir  = $options["OUTPUT_DIR"]
$verbose    = $options["VERBOSE_MODE"]

if images_dir == nil then
  abort "You must specify the root directory of the images you want to create the thumbnails"
end

if output_dir == nil then
  output_dir = images_dir+"/thumbnails"
end

images = Dir.entries(images_dir)
__v("Opening Directory '"+images_dir+"'")


#Removing directory references
images.delete "."
images.delete ".."

if !File.directory? output_dir then
  Dir::mkdir output_dir
end


puts "Processing images, please wait"
puts "Thumbnails size: "+$options["SIZE"].to_s+"\n\n"


#Listing the images
images.each do |image|
    begin
      __v("Processing image '"+images_dir+"/"+image+"'")
      image_file = Magick::Image.read(images_dir+"/"+image).first
      thumb = image_file.resize_to_fill($options["SIZE"].to_i,$options["SIZE"].to_i)
      
      thumb.write output_dir+"/"+image
      __v("Writing image '"+output_dir+"/"+image+"'\n")
      
      if(!$verbose) then
        print ". "
        STDOUT.flush
      end
      
    rescue Exception=>e
      if($options["DISPLAY_WARNINGS"]) then
        puts "\n[Warning] "+e+"\n"
      end
    end
end

puts "\nThumbnails created on folder '"+output_dir+"'"

