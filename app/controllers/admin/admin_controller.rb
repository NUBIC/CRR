class Admin::AdminController < ApplicationController
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  before_action :require_user
  before_action :set_paper_trail_whodunnit

  def require_user
    unless user_signed_in? && current_user.has_system_access?
      flash['error'] = 'Access Denied'
      sign_out @user
      redirect_to public_root_path
      return false
    end
  end

  def set_maintenance_mode
    authorize current_user, :set_maintenance_mode?
    Rails.configuration.custom.maintenance_mode = params[:maintenance_mode] == 'true' ? true : false
    render nothing: true
  end

  private
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:netid) }
    end

    def user_for_paper_trail
      user_signed_in? ? current_user.id : 'Public user'
    end

    def user_not_authorized
      flash['error'] = 'Access Denied'
      redirect_to admin_default_path
    end
end
