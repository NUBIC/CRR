class AccountsController < PublicController
  def index
    @accounts = Account.all
  end

  def dashboard
    @account = current_user
    respond_to do |format|
      format.html
    end
  end

  def new
    @account = Account.new
    respond_to do |format|
      format.html { render :layout=> "public"}
    end
  end

  def edit
    @account = Account.find(params[:id])
  end

  def create
    @account = Account.new(account_params)
    respond_to do |format|
      if @account.save
        format.html { redirect_to dashboard_path }
      else
        format.html { redirect_to public_login_path(:anchor => "sign_up")
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
        format.html { redirect_to dashboard_path }
      else
        flash[:error] = @account.errors.full_messages.to_sentence
        format.html { render :action => "edit" }
      end
    end
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
