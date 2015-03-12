class AccountsController < PublicController
  before_filter :require_user, :only=>[:dashboard, :update, :edit]

  def dashboard
    @account = current_user
    authorize! :dashboard, @account
    @account.inactive_participants.each { |p| p.destroy }
    @participant = Participant.find(params[:participant_id]) if params[:participant_id]
    @active_participants = @account.active_participants
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
    authorize! :edit, @account
  end

  def create
    @account = Account.new(account_params)
    respond_to do |format|
      if @account.save
        format.html { redirect_to dashboard_path }
      else
        format.html { redirect_to public_login_path(:anchor => "sign_up")
        flash[:error] = @account.errors.full_messages.to_sentence }
      end
    end
  end

  def update
    @account = Account.find(params[:id])
    authorize! :update, @account
    if @account.valid_password?(params[:account][:current_password])
      @account.update_attributes(account_params)
      respond_to do |format|
        if @account.save
          format.html { redirect_to dashboard_path }
        else
          flash[:error] = @account.errors.full_messages.to_sentence
          format.html { render :action => "edit" }
        end
      end
    else
      respond_to do |format|
        flash[:error] = "Current password doesn't match. Please try again."
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @account = Account.find(params[:id])
    authorize! :destroy, @account
    @account.destroy
    redirect_to accounts_path
  end

  def account_params
    params.require(:account).permit(:email, :password, :password_confirmation)
  end

  def current_password_params
    params.require(:account).permit(:current_password)
  end

end
