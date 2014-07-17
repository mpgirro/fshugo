class HugoController < ApplicationController
  
  def search
    @query = params[:search_box]
    
    return if @query.nil?
    
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
    
    @results.each do |r|
      puts "found #{r.path}"
    end
    
  
    # render result page
    render "hugo/results"
  end
end
