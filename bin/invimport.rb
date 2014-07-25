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
  
  attr_accessor :descr_map, :idcursor
  
  def initialize
    @descr_map = Hash.new
    @idcursor = 0
  end  
  
  def contains?(descr)
    return false if descr == ""
    return @descr_map.has_value?(descr)
  end
  
  def add(descr)
    unless descr == ""
      @descr_map[idcursor] = descr
      @idcursor += 1
    end
  end

  def get_descr(id)
    return @descr_map[id]
  end
  
  def from_json(json)
    #self.descr_map = Hash.new
    #self.idcursor = 0
    json.each do |entry|
      unless self.contains?(entry["description"])
        self.add(entry["description"])
      end
    end
  end
end # LookupTable


def parse_fstruct(fstruct)
  
  fstruct.each do |entry|
    
    case entry["type"]
    when "directory"
      FileStructureEntity.create( { 
        :entity_type => "directory",
        :path => entry["path"],
        :bytes => entry["bytes"],
        :ctime => entry["ctime"],
        :mtime => entry["mtime"],
        :file_count => entry["file_count"],
        :item_count => entry["item_count"]
      } )
      
      parse_fstruct(entry["file_list"])
      
    when "file"
      
      # subsitute the lookup table ids with them from the db
      mime_descr = @mime_tab.get_descr(entry["mime_id"])
      kind_descr = @kind_tab.get_descr(entry["kind_id"])

      mime_id = MimeTab.where(:description => mime_descr).ids.first
      kind_id = KindTab.where(:description => kind_descr).ids.first
      
      FileStructureEntity.create( { 
        :entity_type => "file",
        :path => entry["path"],
        :bytes => entry["bytes"],
        :ctime => entry["ctime"],
        :mtime => entry["mtime"],
        :mime_id => mime_id,
        :kind_id => kind_id
      } )
    end
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
@mime_tab = LookupTable.new
@mime_tab.from_json(json_data["mime_tab"])

@kind_tab = LookupTable.new
@kind_tab.from_json(json_data["kind_tab"])

@osx_tab = LookupTable.new
@osx_tab.from_json(json_data["osx_tab"])

@fshugo_tab = LookupTable.new
@fshugo_tab.from_json(json_data["fshugo_tab"])

case inv_operation
when "new"
  
  puts "dropping old database entries"
  MimeTab.delete_all
  KindTab.delete_all
  FileStructureEntity.delete_all
  
  # make mime tab
  puts "filling MimeTab"
  json_data["mime_tab"].each do |entry|
    MimeTab.create( {:descr_id => entry["id"], :description => entry["description"] })
  end
  
  # make kind tab
  puts "filling KindTab"
  json_data["kind_tab"].each do |entry|
    KindTab.create( {:descr_id => entry["id"], :description => entry["description"] } )
  end
  
  puts "filling OsxTab"
  json_data["osx_tab"].each do |entry|
    OsxTab.create( {:descr_id => entry["id"], :description => entry["description"] } )
  end
  
  puts "filling FshugoTab"
  json_data["fshugo_tab"].each do |entry|
    FshugoTab.create( {:descr_id => entry["id"], :description => entry["description"] } )
  end
  
  # output this string - yet the function is called outside this block
  puts "filling FileStructureEntity"

when "extend"

  puts "extending MimeTab"
  json_data["mime_tab"].each do |entry|
    unless MimeTab.exists?(:description => entry["description"])
      MimeTab.create( {:description => entry["description"] })
    end
  end
  
  puts "extending KindTab"
  json_data["kind_tab"].each do |entry|
    unless KindTab.exists?(:description => entry["description"])
      KindTab.create( {:description => entry["description"] })
    end
  end
  
  puts "extending OsxTab"
  json_data["osx_tab"].each do |entry|
    unless OsxTab.exists?(:description => entry["description"])
      OsxTab.create( {:description => entry["description"] })
    end
  end
  
  puts "extending FshugoTab"
  json_data["fshugo_tab"].each do |entry|
    unless FshugoTab.exists?(:description => entry["description"])
      FshugoTab.create( {:description => entry["description"] })
    end
  end
  
  # output this string - yet the function is called outside this block
  puts "extending FileStructureEntities"

end

parse_fstruct(json_data["file_structure"])

















