class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  helper_method :mask_query, :unmask_query
  
  BLANK_REPLACE = "$$$"
  
  # escape blank symbols with a special symbol sequence so 
  # they may not be confused with keyword separation signs
  def mask_query(path)
    return path.gsub(" ", BLANK_REPLACE)
  end
  
  # replace the blank symbol escape sequence with blanks again
  def unmask_query(path)
    return path.gsub(BLANK_REPLACE, " ")
  end
  
end
