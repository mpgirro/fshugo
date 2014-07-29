#!/usr/bin/env ruby

require 'rubygems'
require 'json'

module JSON
  class << self
    def parse(source, opts = {})
      opts = ({:max_nesting => 100}).merge(opts)
      Parser.new(source, opts).parse
    end
  end
end

class LookupTable
  
  attr_accessor :val_map, :idcursor
  
  def initialize
    @val_map = Hash.new
    @idcursor = 1
  end  
  
  def contains?(descr)
    return descr == "" ? false : @val_map.has_value?(descr)
  end
  
  def add(descr)
    unless descr == ""
      @val_map[idcursor] = descr
      @idcursor += 1
    end
  end

  def get_value(id)
    return @val_map[id]
  end
  
  def from_json(json)
    json.each do |entry|
      self.add(entry["value"]) unless self.contains?(entry["value"])
    end
  end
end # LookupTable


def parse_fstruct(fstruct)
  
  fstruct.each do |entry|
    
    fse = { 
      :path => entry["path"],
      :bytes => entry["bytes"],
      :ctime => entry["ctime"],
      :mtime => entry["mtime"]
    }
    
    case entry["type"]
    when "directory"
      fse[:entity_type] = "directory"
      fse[:file_count] = entry["file_count"]
      fse[:item_count] = entry["item_count"]
    when "file"
      fse[:entity_type] = "file"
      
      # subsitute the lookup table ids with them from the db
      mime_descr = $mime_tab.get_value(entry["mimetype"])
      mime_id = MimeType.where(:mimetype => mime_descr).ids.first
      fse[:mimetype] = mime_id
      
      magic_descr = $magic_tab.get_value(entry["magicdescr"])
      magic_id = MagicDescription.where(:magicdescr => magic_descr).ids.first
      fse[:magicdescr] = magic_id
    end
    
    osx_tags = [] # will be array of db ids
    unless entry["osx_tags"].nil?
      entry["osx_tags"].each do |json_id|
        tag = $osx_tab.get_value(json_id)
        osx_tags << OsxTag.where(:tag => tag).ids.first
      end
    end
    fse[:osx_tags] = osx_tags
    
    fshugo_tags = [] # will be array of db ids
    unless entry["fshugo_tags"].nil?
      entry["fshugo_tags"].each do |json_id|
        tag = $fshugo_tab.get_value(json_id)
        fshugo_tags << FshugoTag.where(:tag => tag).ids.first
      end
    end
    fse[:fshugo_tags] = fshugo_tags
    
    FileStructure.create(fse)
    
    parse_fstruct(entry["file_list"]) if entry["type"] == "directory"
    
  end
end

APP_PATH = File.expand_path('../../config/application',  __FILE__)
require File.expand_path('../../config/boot',  __FILE__)
require APP_PATH
# set Rails.env here if desired
Rails.application.require_environment!

USAGE = "Usage: invimport.rb <new|extend> inventory_file"
SUPPORTED_OPERATIONS = ["new", "extend"]

if ARGV[0].nil? 
  puts "Now operation provided"
  puts USAGE
  exit
end

if ARGV[1].nil?
  puts "No inventory file provided"
  puts USAGE
  exit
end


inv_operation = ARGV[0]
invfile_path  = ARGV[1]

unless SUPPORTED_OPERATIONS.include?(inv_operation)
  puts "Operation \"#{inv_operation}\" not supported"
  puts USAGE
  exit
end

if File.directory?(invfile_path)
  puts "#{invfile_path} is a directory -- file needed!"
  exit
end

unless File.exists?(invfile_path)
  puts "File does not exist: #{invfile_path}"
  exit
end

puts "reading #{invfile_path}"
f = File.open(invfile_path, "r")
json_string = ""

# read all lines into one large array
# is fast, but takes way more memory
json_string = f.readlines.join

# Use this if you need low memory usage
# but keep in mind, this is very slow
# about 44h to read file with 800.000 lines
#
#f.each_line do |line|
#  puts "adding #{line}"
#  json_string += line
#end
#
f.close

puts "parsing json"
json_data = JSON.parse(json_string, :max_nesting => 100)


# first we have to reconstruct the lookup tables (we need them globally)
$mime_tab = LookupTable.new
$mime_tab.from_json(json_data["mime_tab"]) unless json_data["mime_tab"].nil?

$magic_tab = LookupTable.new
$magic_tab.from_json(json_data["magic_tab"]) unless json_data["magic_tab"].nil?

$osx_tab = LookupTable.new
$osx_tab.from_json(json_data["osx_tab"]) unless json_data["osx_tab"].nil?

$fshugo_tab = LookupTable.new
$fshugo_tab.from_json(json_data["fshugo_tab"]) unless json_data["fshugo_tab"].nil? 

case inv_operation
when "new"
  
  puts "dropping old database entries"  
  MimeType.delete_all
  MagicDescription.delete_all
  OsxTag.delete_all
  FshugoTag.delete_all
  
  FileStructure.delete_all
  
  # make mime tab
  puts "filling MimeType"
  unless json_data["mime_tab"].nil?
    json_data["mime_tab"].each do |entry|
      MimeType.create( {:mimetype => entry["value"] })
    end
  end
  
  # make kind tab
  puts "filling MagicDescription"
  unless json_data["magic_tab"].nil?
    json_data["magic_tab"].each do |entry|
      MagicDescription.create( {:magicdescr => entry["value"] } )
    end
  end
  
  puts "filling OsxTag"
  unless json_data["osx_tab"].nil?
    json_data["osx_tab"].each do |entry|
      OsxTag.create( {:tag => entry["value"] } )
    end
  end  
  
  puts "filling FshugoTag"
  unless json_data["fshugo_tab"].nil?
    json_data["fshugo_tab"].each do |entry|
      FshugoTag.create( {:tag => entry["value"] })
    end
  end
  
  # output this string - yet the function is called outside this block
  puts "filling FileStructure"

when "extend"

  puts "extending MimeType"
  unless json_data["mime_tab"].nil?
    json_data["mime_tab"].each do |entry|
      MimeType.create( {:mimetype => entry["value"] }) unless MimeType.exists?(:mimetype => entry["value"])
    end
  end
  
  puts "extending MagicDescription"
  unless json_data["magic_tab"].nil?
    json_data["magic_tab"].each do |entry|
      MagicDescription.create( {:magicdescr => entry["value"] }) unless MagicDescription.exists?(:magicdescr => entry["value"])
    end
  end
  
  puts "extending OsxTag"
  unless json_data["osx_tab"].nil?
    json_data["osx_tab"].each do |entry|
      OsxTag.create( {:tag => entry["value"] }) unless OsxTag.exists?(:tag => entry["value"])
    end
  end
  
  puts "extending FshugoTag"
  unless json_data["fshugo_tab"].nil?
    json_data["fshugo_tab"].each do |entry|
      FshugoTag.create( {:tag => entry["value"] }) unless FshugoTag.exists?(:tag => entry["value"])
    end
  end
  
  # output this string - yet the function is called outside this block
  puts "extending FileStructure"

end

parse_fstruct(json_data["file_structure"])

















