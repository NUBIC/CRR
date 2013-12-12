class PublicController < ApplicationController
  layout "layouts/public"
  helper_method :current_user

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error]="Access Denied"
    if current_user
      redirect_to dashboard_url
    else
      redirect_to public_login_url
    end
  end

  private

  def current_account_session
    return @current_account_session if defined?(@current_account_session)
    @current_account_session ||= AccountSession.find
  end

  def current_user
    #return @current_user if defined?(@current_user)
    @current_user = current_account_session && current_account_session.record
  end

  def require_user
    if current_user.blank?
      store_location
      flash[:info] = "Please login or create a new account"
      redirect_to public_login_url
      return false
    end
  end

  def require_no_user
    if current_user
      flash[:notice]="You are currently logged in"
      redirect_to dashboard_url
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end
end
