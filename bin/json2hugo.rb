#!/usr/bin/env ruby

require 'rubygems'
require 'json'

def parse_fstruct(fstruct)
  
  fstruct.each do |entry|
    case entry["type"]
    when "directory"
      FileStructureEntities.new( { 
        :type => "directory",
        :path => entry["path"],
        :bytes => entry["bytes"],
        :ctime => entry["ctime"],
        :mtime => entry["mtime"],
        :file_count => entry["file_count"]
        :item_count => entry["item_count"]
      } )
      parse_fstruct(entry["file_list"])
    when "file"
      FileStructureEntities.new( { 
        :type => "file",
        :path => entry["path"],
        :bytes => entry["bytes"],
        :ctime => entry["ctime"],
        :mtime => entry["mtime"],
        :mime_id => entry["mime_id"]
        :kind_id => entry["kind_id"]
      } )
    end
  end
end

#APP_PATH = File.expand_path('../../config/application',  __FILE__)
require File.expand_path('../../config/boot',  __FILE__)
require APP_PATH
# set Rails.env here if desired
Rails.application.require_environment!


if ARGV[0].nil? 
  puts "No inventory file provided"
  #puts USAGE
  exit
end

invfile_path = ARGV[0]

f = File.open(invfile_path, "r")

json_string = ""
f.each_line do |line|
  json_string += line
end
f.close


json_data = JSON.parse(json_string, :max_nesting => 100)

# make mime tab
json_data["mime_tab"].each do |entry|
  puts "processing #{entry["id"]} : #{entry["description"]}"
  MimeTab.create( {:id => entry["id"], :description => } entry["description"] )
end

# make kind tab
json_data["kind_tab"].each do |entry|
  puts "processing #{entry["id"]} : #{entry["description"]}"
  KindTab.create( {:id => entry["id"], :description => } entry["description"] )
end

parse_fstruct(json_data["file_structure"])



