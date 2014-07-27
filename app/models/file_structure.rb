class FileStructure < ActiveRecord::Base
  attr_accessible :path, :bytes, :ctime, :mtime, :entity_type
  attr_accessible :file_count, :item_count # used if referencing a directory
  attr_accessible :mimetype, :magicdescr # used if referencing a file
  attr_accessible :osx_tags, :fshugo_tags
  
  serialize :osx_tags,Array    # tags is text type, make it behave like an array
  serialize :fshugo_tags,Array # tags is text type, make it behave like an array
  
  def scores(keywords)
    return {
      :byte_score => bytes_score,
      :name_score => name_score(keywords),
      :slash_score => slash_score,
      :tag_score => tag_score(keywords)
    }
  end
  
  # rates the item by its bytes sizes. it assumes 
  # that larger files/directories are more desireable
  private 
  def bytes_score
    return self.bytes
  end
  
  # rates the item by their file/directory names.
  # best results are gained if the keywords are all 
  # part of the file/directory names. otherwise it 
  # is (contained keywords / total keywords)
  private 
  def name_score(keywords)
    score = 0
    keywords.each do |keyword|
      score += 1 if File.basename(self.path).downcase.include?(keyword.downcase)
    end

    return score.to_f / keywords.length.to_f
  end
  
  # rates the item by the amount of slashes in its path.
  # it is asumed that a result with few slashes has the keywords
  # in a very upper level of the file system hierarchy
  # note: it does not say anything about the relativ position of 
  # the keywords inside the path or their distance from each
  # other 
  private 
  def slash_score
    return self.path.split('/').length-1
  end
  
  private 
  def tag_score(keywords)
    # TODO
  end
  
end
