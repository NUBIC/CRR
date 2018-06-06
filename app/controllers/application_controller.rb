class ApplicationController < ActionController::Base
  include Pundit
  after_action :verify_authorized, unless: :devise_controller?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  protect_from_forgery with: :null_session
  after_action  :flash_headers
  before_action :set_no_cache
  before_action :check_maintenance_mode

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render text: exception, status: 500
  end

  private
    def flash_headers
      # This will discontinue execution if Rails detects that the request is not
      # from an AJAX request, i.e. the header wont be added for normal requests
      if request.xhr?
        # add flash notices to reesponse header
        response.headers['x-flash-notice'] = flash['notice']  unless flash['notice'].blank?
        response.headers['x-flash-errors'] = flash['error']   unless flash['error'].blank?
        # Stops the flash appearing when you next refresh the page
        flash.discard
      end
    end

    def set_no_cache
      response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
      response.headers['Pragma']        = 'no-cache'
      response.headers['Expires']       = '0'
    end

    def check_maintenance_mode
      if Rails.configuration.maintenance_mode
        unless current_user && current_user.is_a?(User) && current_user.active? && current_user.admin? || current_user.blank? && ['users', 'sessions'].include?(controller_name)
          render file: '/public/maintenance.html', layout: false
        end
      end
    end

    def user_not_authorized
      flash['notice'] = 'Access Denied'
      redirect_to default_path
    end
end
