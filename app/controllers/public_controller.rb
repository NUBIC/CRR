class PublicController < ApplicationController
  layout 'layouts/public'
  helper_method :current_user

  def handle_unverified_request
    super
    cookies.delete 'account_credentials'
    @current_account_session = @current_user = nil
  end

  private
    def current_account_session
      return @current_account_session if defined?(@current_account_session)
      @current_account_session ||= AccountSession.find
    end

    def current_user
      @current_user = current_account_session && current_account_session.record
    end

    def require_user
      if current_user.blank?
        store_location
        flash['info'] = 'Please login or create a new account'
        redirect_to public_login_url
        return false
      end
    end

    def require_no_user
      if current_user
        flash['notice'] = 'You are currently logged in'
        redirect_to dashboard_url
      end
    end

    def store_location
      session[:return_to] = request.fullpath
    end

    def user_not_authorized
      flash['error'] = 'Access Denied'
      if current_user
        redirect_to dashboard_url
      else
        redirect_to public_login_url
      end
    end
end
