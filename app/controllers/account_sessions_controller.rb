class AccountSessionsController < PublicController
  before_filter :require_no_user, :only=>[:new]
  before_filter :require_user, :only=>[:destroy]
  # GET /account_sessions/new
  def new
    @account_session = AccountSession.new

    respond_to do |format|
      if current_user
        format.html { redirect_to dashboard_path }
      else
        format.html
      end
    end
  end

  # POST /account_sessions
  def create
    @account_session = AccountSession.new(params[:account_session])
    if @account_session.save
      redirect_to dashboard_path
    else
      flash[:error] = @account_session.errors.full_messages.to_sentence
      redirect_to public_login_path(:anchor => "login_tab")
    end
  end

  # DELETE /account_sessions/1
  def destroy
    @account_session = AccountSession.find
    @account_session.destroy
    redirect_to :public_login
  end
end
