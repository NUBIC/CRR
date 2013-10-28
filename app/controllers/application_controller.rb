class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  after_filter :flash_headers
  helper_method :current_user

  def flash_headers
    # This will discontinue execution if Rails detects that the request is not
    # from an AJAX request, i.e. the header wont be added for normal requests
    return unless request.xhr?
    # add flash notices to reesponse header
    response.headers['x-flash'] = flash[:error]  unless flash[:error].blank?
    response.headers['x-flash'] = flash[:notice]  unless flash[:notice].blank?
    # Stops the flash appearing when you next refresh the page
    flash.discard
  end

  private

  def current_account_session
    return @current_account_session if defined?(@current_account_session)
    @current_account_session ||= AccountSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_account_session && current_account_session.record
  end
end
