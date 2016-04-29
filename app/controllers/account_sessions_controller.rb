class AccountSessionsController < PublicController
  before_action :require_no_user, only: :new
  before_action :require_user,    only: :destroy

  def new
    @account_session = AccountSession.new
    authorize @account_session
    respond_to do |format|
      if current_user
        format.html { redirect_to dashboard_path }
      else
        format.html
      end
    end
  end

  def create
    @account_session = AccountSession.new(params[:account_session])
    authorize @account_session
    if @account_session.save
      redirect_to dashboard_path
    else
      flash['error'] = @account_session.errors.full_messages.to_sentence
      redirect_to public_login_path( anchor: 'login_tab' )
    end
  end

  def destroy
    @account_session = AccountSession.find
    authorize @account_session
    @account_session.destroy
    redirect_to AudiologyRegistry::Application.config.crr_website_url
  end

  def back_to_website
    authorize AccountSession
    redirect_to current_user ? :public_logout : AudiologyRegistry::Application.config.crr_website_url
  end
end
