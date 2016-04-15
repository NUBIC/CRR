class Admin::AdminController < ApplicationController
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  before_filter :require_user
  before_filter :set_paper_trail_whodunnit


  # can can redirect for unauthorized error
  rescue_from CanCan::AccessDenied do |exception|
    flash['notice'] = 'Access Denied'
    redirect_to admin_default_path
  end

  def require_user
    unless user_signed_in? && current_user.has_system_access?
      flash['notice'] = 'Access Denied'
      redirect_to '/logout'
      return false
    end
  end

  def set_maintenance_mode
    Rails.configuration.custom.maintenance_mode = params[:maintenance_mode] == 'true' ? true : false
    render nothing: true
  end

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:netid) }
    end

    def user_for_paper_trail
      user_signed_in? ? current_user.id : 'Public user'
    end
end

