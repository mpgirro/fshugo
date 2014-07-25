class FileStructureEntity < ActiveRecord::Base
  attr_accessible :path, :bytes, :ctime, :mtime, :entity_type
  attr_accessible :file_count, :item_count # used if referencing a directory
  attr_accessible :mime_id, :kind_id # used if referencing a file
  attr_accessible :osx_tags, :fshugo_tags
  
  serialize :osx_tags,Array    # tags is text type, make it behave like an array
  serialize :fshugo_tags,Array # tags is text type, make it behave like an array
end
