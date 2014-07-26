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
    @idcursor = 1
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
      mime_descr = $mime_tab.get_descr(entry["mime_id"])
      mime_id = MimeTab.where(:description => mime_descr).ids.first
      fse[:mime_id] = mime_id
      
      kind_descr = $kind_tab.get_descr(entry["kind_id"])
      kind_id = KindTab.where(:description => kind_descr).ids.first
      fse[:kind_id] = kind_id
    end
    
    osx_tags = [] # will be array of db ids
    unless entry["osx_tags"].nil?
      entry["osx_tags"].each do |json_id|
        tag = $osx_tab.get_descr(json_id)
        osx_tags << OsxTab.where(:description => tag).ids.first
      end
    end
    
    fshugo_tags = [] # will be array of db ids
    unless entry["fshugo_tags"].nil?
      entry["fshugo_tags"].each do |json_id|
        tag = $fshugo_tab.get_descr(json_id)
        fshugo_tags << FshugoTab.where(:description => tag).ids.first
      end
    end
    fse[:osx_tags] = osx_tags
    fse[:fshugo_tags] = fshugo_tags
    
    FileStructureEntity.create( fse )
    
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

$kind_tab = LookupTable.new
$kind_tab.from_json(json_data["kind_tab"]) unless json_data["kind_tab"].nil?

$osx_tab = LookupTable.new
$osx_tab.from_json(json_data["osx_tab"]) unless json_data["osx_tab"].nil?

$fshugo_tab = LookupTable.new
$fshugo_tab.from_json(json_data["fshugo_tab"]) unless json_data["fshugo_tab"].nil? 

case inv_operation
when "new"
  
  puts "dropping old database entries"
  MimeTab.delete_all
  KindTab.delete_all
  OsxTab.delete_all
  FshugoTab.delete_all
  FileStructureEntity.delete_all
  
  # make mime tab
  puts "filling MimeTab"
  unless json_data["mime_tab"].nil?
    json_data["mime_tab"].each do |entry|
      MimeTab.create( {:description => entry["description"] })
    end
  end
  
  # make kind tab
  puts "filling KindTab"
  unless json_data["kind_tab"].nil?
    json_data["kind_tab"].each do |entry|
      KindTab.create( {:description => entry["description"] } )
    end
  end
  
  puts "filling OsxTab"
  unless json_data["osx_tab"].nil?
    json_data["osx_tab"].each do |entry|
      OsxTab.create( {:description => entry["description"] } )
    end
  end  
  
  puts "filling FshugoTab"
  unless json_data["fshugo_tab"].nil?
    json_data["fshugo_tab"].each do |entry|
      FshugoTab.create( {:description => entry["description"] })
    end
  end
  
  # output this string - yet the function is called outside this block
  puts "filling FileStructureEntity"

when "extend"

  puts "extending MimeTab"
  unless json_data["mime_tab"].nil?
    json_data["mime_tab"].each do |entry|
      unless MimeTab.exists?(:description => entry["description"])
        MimeTab.create( {:description => entry["description"] })
      end
    end
  end
  
  puts "extending KindTab"
  unless json_data["kind_tab"].nil?
    json_data["kind_tab"].each do |entry|
      unless KindTab.exists?(:description => entry["description"])
        KindTab.create( {:description => entry["description"] })
      end
    end
  end
  
  puts "extending OsxTab"
  unless json_data["osx_tab"].nil?
    json_data["osx_tab"].each do |entry|
      unless OsxTab.exists?(:description => entry["description"])
        OsxTab.create( {:description => entry["description"] })
      end
    end
  end
  
  puts "extending FshugoTab"
  unless json_data["fshugo_tab"].nil?
    json_data["fshugo_tab"].each do |entry|
      unless FshugoTab.exists?(:description => entry["description"])
        FshugoTab.create( {:description => entry["description"] })
      end
    end
  end
  
  # output this string - yet the function is called outside this block
  puts "extending FileStructureEntities"

end

parse_fstruct(json_data["file_structure"])

















