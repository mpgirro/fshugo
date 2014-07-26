class HugoController < ApplicationController
    
  def search
    @query = params[:q]
    
    return if @query.nil?
    return if @query == ""
    
    puts "searching for: #{unmask_query(@query)}"
    
    @keywords = @query.split(" ")
    
    # extract conditions, make fit for sql usage
    conditions = []
    @keywords.each do |part|
      # substitute wildcard symbols
      part = part.gsub("%", "\%")
      part = part.gsub("_", "\_")
      part = unmask_query(part) # make sure dirlinks are searched correctly
      part =  "%" + part + "%"
      conditions << part
    end
    
    # make conditions string
    condition_base = "path LIKE ? AND "
    condition_string = ""
    conditions.each do |condition|
      condition_string += condition_base
    end
    condition_string = condition_string[0, condition_string.length - "AND ".length]
    
    # make conditions array
    cond = []
    cond << condition_string
    conditions.each do |c|
      cond << c
    end
    
    # do the search
    result_records = FileStructureEntity.where(cond)
    @results = result_records.to_a.map(&:serializable_hash)
    #@results = FileStructureEntity.where(cond)
  
    # do the rating
    rate_results unless @results.nil? || @results.empty?
  
    # render result page
    render "hugo/search_result"
  end
  
  private 
  def rate_results()
    
    # build a map of all FSEs
    namescore_map = name_scores 
    bytescore_map = bytes_scores
    pathscore_map = slash_scores
    score_map = {}
    @results.each do |resitem|
      score_map[resitem] = bytescore_map[resitem] + pathscore_map[resitem] + namescore_map[resitem] unless resitem.nil?
    end

    # now "sort" the map (sounds wrong, I know) by score
    sorted_map = Hash[score_map.sort_by{|k, v| v}.reverse]
    
    @results = sorted_map.keys
    
  end # rate_results
  
  # rates the items by their bytes sizes. it assumes 
  # that larger files/directories are more desireable
  private
  def bytes_scores()
    
    # put the bytes of every resitem into a map
    score_map = {}
    @results.each do |resitem|
      bytes = resitem["bytes"]
      score_map[resitem] = bytes
    end
    
    # return normalized scores - more bytes are better
    return normalize_highscores(score_map)
  end
  
  # rates the items by their file/directory names.
  # best results are gained if the keywords are all 
  # part of the file/directory names. otherwise it 
  # is (contained keywords / total keywords)
  private
  def name_scores()
    
    score_map = {}
    @results.each do |resitem|
      
      # calculate how many keywords each file/directory name contains
      score = 0
      @keywords.each do |keyword|
        score += 1 if File.basename(resitem["path"]).downcase.include?(keyword.downcase)
      end

      #unless score == 0 
        score_map[resitem] = score.to_f / @keywords.length.to_f
      #else
      #  @results.delete(resitem)
      #end
    end

    # return normalized scores - more conains are better
    return normalize_highscores(score_map)
  end
  
  # rates items by the amount of slashes in their paths.
  # it is asumed that a result with few slashes has the keywords
  # in a very upper level of the file system hierarchy
  # note: it does not say anything about the relativ position of 
  # the keywords inside the path or their distance from each
  # other 
  private 
  def slash_scores()
    
    # calculate the number of slashes in every path
    score_map = {}
    @results.each do |resitem|
      slashcount = resitem["path"].split('/').length-1
      score_map[resitem] = slashcount
    end

    # return normalized scores - small few slashes are better
    return normalize_lowscores(score_map)
  end
  
  private
  def normalize_lowscores(score_map)
    # normalize the scores - small slashcount is better
    vsmall = 0.000001 # avoid division by 0
    bestscore = score_map.values.min # this is the smallest slash count found
    bestscore = vsmall if bestscore < vsmall
    score_map.each do |resitem,score|
      score = vsmall if score < vsmall
      score_map[resitem] = bestscore.to_f / score.to_f
    end
    return score_map
  end
  
  private
  def normalize_highscores(score_map)
    vsmall = 0.000001 # avoid division by 0
    bestscore = score_map.values.max # the most bytes found
    bestscore = vsmall if bestscore < vsmall
    score_map.each do |resitem,score|
      score_map[resitem] = score.to_f / bestscore.to_f
    end
    return score_map    
  end
  
end
