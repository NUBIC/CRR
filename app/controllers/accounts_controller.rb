class AccountsController < ApplicationController
  def index
    @accounts = Account.all
  end

  def new
    @account = Account.new
    respond_to do |format|
      format.html { render :layout=> "public"}
    end
  end

  def create
    @account = Account.new(account_params)
    respond_to do |format|
      if @account.save
        format.html {  redirect_to(@account, :notice => 'Account is created') }
      else
        format.html { redirect_to login_path(:anchor => "sign_up")
        flash[:notice] = "Please try again" }
      end
    end
  end

  def update
    @account = Account.find(params[:id])
    @account.update_attributes(account_params)
    respond_to do |format|
      if @account.save
        flash[:notice] = "Updated"
        format.html { redirect_to account_path(@account) }
      else
        flash[:error] = @account.errors.full_messages.to_sentence
        format.html { render :action => "edit" }
      end
    end
    # redirect_to account_path(@account)
  end

  def destroy
    @account = Account.find(params[:id])
    @account.destroy
    redirect_to accounts_path
  end

  def account_params
    params.require(:account).permit(:email, :password, :password_confirmation)
  end

end