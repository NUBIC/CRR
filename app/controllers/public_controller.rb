class PublicController < ApplicationController
  layout "layouts/public"
  helper_method :current_user
  private

  def current_account_session
    return @current_account_session if defined?(@current_account_session)
    @current_account_session ||= AccountSession.find
  end

  def current_user
    #return @current_user if defined?(@current_user)
    @current_user = current_account_session && current_account_session.record
  end
  def require_account
    if current_user.blank?
      store_location
      flash[:notice] = "Please login or create a new account"
      redirect_to public_login_url
      return false
    end
  end
  def store_location
    session[:return_to] = request.fullpath
  end
end
