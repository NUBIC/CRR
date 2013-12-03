class AccountSessionsController < PublicController
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

    respond_to do |format|
      if @account_session.save
        format.html { redirect_to dashboard_path }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # DELETE /account_sessions/1
  def destroy
    @account_session = AccountSession.find
    @account_session.destroy
    redirect_to :public_login
  end
end
