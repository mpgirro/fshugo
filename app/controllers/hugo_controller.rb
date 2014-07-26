class HugoController < ApplicationController
    
  VERY_SMALL = 0.000001 # avoid division by 0
    
  def search
    @query = params[:q]
    
    return if @query.nil?
    return if @query == ""
    
    puts "searching for: #{unmask_query(@query)}"
    
    @keywords = @query.split(" ")
    
    # extract conditions, make fit for sql usage
    condition_keywords = []
    @keywords.each do |keyword|
      condition_keywords << "%" + unmask_query(keyword).gsub("_", "\_").gsub("%", "\%") + "%"
    end
    
    condition = [] << (["path LIKE ?"] * @keywords.length).join(" AND ")
    condition += condition_keywords # => ["path like ? and path like ?", "keyword1", "keyword2"]
    
    # do the search
    @results = FileStructureEntity.where(condition)
    #@results = FileStructureEntity.where(condition).to_a.map(&:serializable_hash) # ActiveRecord to Array

    # do the rating
    rate_results unless @results.nil? || @results.empty?
  
    # render result page
    render "hugo/search_result"
  end
  
  private
  def rate_results
    
    namescore_map = {}
    bytescore_map = {}
    slashscore_map = {}
    
    # collect the scores
    @results.each do |resitem|
      item_scores = resitem.scores(@keywords)
      namescore_map[resitem] = item_scores[:name_score]
      bytescore_map[resitem] = item_scores[:byte_score]
      slashscore_map[resitem] = item_scores[:slash_score]
    end
    
    # normalize the scores
    bytescore_map = normalize_highscores(bytescore_map)
    namescore_map = normalize_highscores(namescore_map)
    slashscore_map = normalize_lowscores(slashscore_map)
    
    # put the scores together
    score_map = {}
    @results.each do |resitem|
      score_map[resitem] = bytescore_map[resitem] 
                         + slashscore_map[resitem] 
                         + namescore_map[resitem] unless resitem.nil?
    end
    
    # now "sort" the map (sounds wrong, I know) by score
    sorted_map = Hash[score_map.sort_by{|k, v| v}.reverse]
    
    @results = sorted_map.keys
    
  end # rate_results
  
  # normalize the scores, mapping them into the range (0,1)
  # small score value is assumed better, therefore the 
  # smallest will be mapped to 1
  private
  def normalize_lowscores(score_map)
    bestscore = (bestscore < VERY_SMALL ? VERY_SMALL : score_map.values.min )
    score_map.each do |resitem,score|
      score = vsmall if score < vsmall
      score_map[resitem] = bestscore.to_f / score.to_f
    end
    return score_map
  end
  
  # normalize the scores, mapping them into the range (0,1)
  # high score value is assumed better, therefore the 
  # highest will be mapped to 1
  private
  def normalize_highscores(score_map)
    bestscore = (bestscore < VERY_SMALL ? VERY_SMALL : score_map.values.max )
    score_map.each do |resitem,score|
      score_map[resitem] = score.to_f / bestscore.to_f
    end
    return score_map    
  end
  
end
