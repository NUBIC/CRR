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
end
