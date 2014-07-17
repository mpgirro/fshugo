class FileStructureEntity < ActiveRecord::Base
  attr_accessible :path, :bytes, :ctime, :mtime, :type
  attr_accessible :file_count, :item_count # used if referencing a directory
  attr_accessible :mime_id, :kind_id # used if referencing a file
end
