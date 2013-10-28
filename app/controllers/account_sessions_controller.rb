class AccountSessionsController < ApplicationController
  layout "/layouts/public"
  # GET /account_sessions/new
  # GET /account_sessions/new.xml
  def new
    @account_session = AccountSession.new
     
    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @account_session }
    end
  end
   
  # POST /account_sessions
  # POST /account_sessions.xml
  def create
    @account_session = AccountSession.new(params[:account_session])
     
    respond_to do |format|
      if @account_session.save
        format.html { redirect_to(:accounts, :notice => 'Login Successful') }
        format.xml { render :xml => @account_session, :status => :created, :location => @account_session }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @account_session.errors, :status => :unprocessable_entity }
      end
    end
  end
   
  # DELETE /account_sessions/1
  # DELETE /account_sessions/1.xml
  def destroy
    @account_session = AccountSession.find
    @account_session.destroy
    redirect_to welcome_index_path
    flash[:notice] = "Successfully logged out"
  end
end