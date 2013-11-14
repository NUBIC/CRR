class Admin::AdminController < ApplicationController
  include Aker::Rails::SecuredController
  before_filter :require_user
  #can can redirect for unauthorized error
  rescue_from CanCan::AccessDenied do |exception|
    flash[:notice]="Access Denied"
    return redirect_to default_path
  end 

  def require_user
    unless current_user.has_system_access?
      flash[:notice] = "Access Denied"
      redirect_to '/logout'
      return false
    end
  end
end

