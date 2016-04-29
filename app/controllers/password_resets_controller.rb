class PasswordResetsController < PublicController
  before_action :require_no_user
  before_action :load_account_using_perishable_token, only: [:edit, :update]

  def create
    @account = Account.find_by_email(params[:email])
    authorize @account, :reset_password_create?
    if @account
      @account.reset_token
      PasswordResetMailer.password_reset_instructions(@account).deliver_now!
      flash['notice'] = 'Instructions to reset your password have been emailed to you'
      redirect_to public_login_url
    else
      flash['error'] = "Unknown email address: #{params[:email]}."
      redirect_to public_login_url(anchor: 'password_reset_tab')
    end
  end

  def edit
    authorize @account, :reset_password_edit?
  end

  def update
    @account.update_attributes(password_params)
    authorize @account, :reset_password_update?

    if @account.save
      redirect_to dashboard_path
    else
      flash['error'] = @account.errors.full_messages.to_sentence
      render action: :edit
    end
  end

  private
    def load_account_using_perishable_token
      @account = Account.find_using_perishable_token(params[:id])
      unless @account
        flash['error'] = 'We\'re sorry, but we could not locate your account'
        redirect_to public_login_url
      end
    end

    def password_params
      params.require(:account).permit(:password, :password_confirmation)
    end
end
