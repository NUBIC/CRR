class AccountSessionsController < ApplicationController
  layout "/layouts/public"
  # GET /account_sessions/new
  def new
    @account_session = AccountSession.new
     
    respond_to do |format|
      format.html # new.html.erb
    end
  end
   
  # POST /account_sessions
  def create
    @account_session = AccountSession.new(params[:account_session])
     
    respond_to do |format|
      if @account_session.save
        format.html { redirect_to dashboard_path
                      flash[:notice] = "Login Successful" }
      else
        format.html { render :action => "new" }
      end
    end
  end
   
  # DELETE /account_sessions/1
  def destroy
    @account_session = AccountSession.find
    @account_session.destroy
    redirect_to welcome_index_path
    flash[:notice] = "Successfully logged out"
  end
end