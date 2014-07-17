class FileStructureEntity < ActiveRecord::Base
  attr_accessible :path, :bytes, :ctime, :mtime, :type
end
