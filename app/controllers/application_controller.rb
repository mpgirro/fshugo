class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  helper_method :escape_path, :capture_path
  
  QUERY_BLANK_ESCAPE = "$$$"
  
  # escape blank symbols with a special symbol sequence so 
  # they may not be confused with keyword separation signs
  def escape_path(path)
    return path.gsub(" ", QUERY_BLANK_ESCAPE)
  end
  
  # replace the blank symbol escape sequence with blanks again
  def capture_path(path)
    return path.gsub(QUERY_BLANK_ESCAPE, " ")
  end
  
end
