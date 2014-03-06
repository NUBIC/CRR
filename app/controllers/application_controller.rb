class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  protect_from_forgery with: :null_session
  after_filter :flash_headers
  before_filter :set_no_cache

  def flash_headers
    # This will discontinue execution if Rails detects that the request is not
    # from an AJAX request, i.e. the header wont be added for normal requests
    return unless request.xhr?
    # add flash notices to reesponse header
    response.headers['x-flash-notice'] = flash[:notice]  unless flash[:notice].blank?
    response.headers['x-flash-errors'] = flash[:error]  unless flash[:error].blank?
    # Stops the flash appearing when you next refresh the page
    flash.discard
  end

  def set_no_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end

end
