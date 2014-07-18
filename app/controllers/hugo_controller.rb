class HugoController < ApplicationController
  
  def search
    @query = params[:q]
    
    return if @query.nil?
    return if @query == ""
    
    puts "searching for: #{@query}"
    
    parts = @query.split(" ")
    
    # extract conditions, make fit for sql usage
    conditions = []
    parts.each do |part|
      # substitute wildcard symbols
      #part["%"] = '\%'
      #part["_"] = '\_'
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
    #@results = FileStructureEntity.find(:all, :conditions => cond)
    @results = FileStructureEntity.where(cond)
  
    # do the rating
    result_rating
    
    @results.each do |r|
      puts "found #{r.path}"
    end
    
  
    # render result page
    render "hugo/search_result"
  end
  
  
  
  private 
  def result_rating()
    
    # build a map of all FSEs
    bytescore_map = bytes_scores
    pathscore_map = path_scores
    score_map = {}
    @results.each do |resitem|
      score_map[resitem] = bytescore_map[resitem] + pathscore_map[resitem]
    end

    # now "sort" the map (sounds wrong, I know) by score
    sorted_map = Hash[score_map.sort_by{|k, v| v}.reverse]
    
    @results = sorted_map.keys
    
  end # result_rating
  
  private
  def bytes_scores()
    
    # put the bytes of every resitem into a map
    score_map = {}
    @results.each do |resitem|
      bytes = resitem.bytes
      score_map[resitem] = bytes
    end
    
    # normalize the scores - more bytes is better
    vsmall = 0.000001 # avoid division by 0
    bestscore = score_map.values.max # the most bytes found
    bestscore = vsmall if bestscore < vsmall
    score_map.each do |resitem,score|
      score_map[resitem] = score.to_f / bestscore.to_f
    end

    return score_map
  end
  
  private 
  def path_scores()
    
    # calculate the number of slashes in every path
    score_map = {}
    @results.each do |resitem|
      slashcount = resitem.path.split('/').length-1
      score_map[resitem] = slashcount
    end
    
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
  
end
