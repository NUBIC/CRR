class AccountsController < PublicController
  include EmailNotifications

  before_action :require_user, only: [:dashboard, :update, :edit]
  before_action :set_account, only: [:edit, :update]

  def create
    @account = Account.new(account_params)
    authorize @account
    respond_to do |format|
      if @account.save
        format.html { redirect_to dashboard_path }
        welcome_email = EmailNotification.active.welcome_participant
        if welcome_email
          outbound_email(@account.email, welcome_email.content,  welcome_email.subject)
        else
          admin_notification = 'ATTENTION: "welcome participant" notification email message could not be sent (corresponding email could have been deactivated)'
          admin_email(admin_notification, 'Communication research registry sign up notification failure')
        end
      else
        format.html { redirect_to public_login_path(anchor: 'sign_up')
        flash['error'] = @account.errors.full_messages.to_sentence }
      end
    end
  end

  def edit
    authorize @account
  end

  def update
    authorize @account
    if @account.valid_password?(params[:account][:current_password])
      @account.update_attributes(account_params)
      respond_to do |format|
        if @account.save
          format.html { redirect_to dashboard_path }
        else
          flash['error'] = @account.errors.full_messages.to_sentence
          format.html { render action: 'edit' }
        end
      end
    else
      respond_to do |format|
        flash['error'] = 'Current password doesn\'t match. Please try again.'
        format.html { render action: 'edit' }
      end
    end
  end

  def dashboard
    @account = current_user
    authorize @account
    @account.inactive_participants.each { |p| p.destroy }
    @participant = Participant.find(params[:participant_id]) if params[:participant_id]
    @active_participants = @account.active_participants
    respond_to do |format|
      format.html
    end
  end

  def express_sign_up
    authorize Account
    errors = express_signup_validation_errors(params)
    respond_to do |format|
      if errors.empty?
        confirmation_message = 'Thank you for your interest in the Communication Research Registry.'
        if params[:contact] == 'email'
          express_sign_up_email = EmailNotification.active.express_sign_up
          if express_sign_up_email
            outbound_email(params[:email], express_sign_up_email.content, express_sign_up_email.subject)
            admin_email(express_sign_up_email_contact_text(params[:name], params[:email]), 'Communication research registry express sign up notification')
            confirmation_message << ' We have sent a reminder to your email address.'
          else
            admin_notification = 'ATTENTION: "express sign up" notification email message could not be sent (corresponding email could have been deactivated)'
            admin_email(admin_notification, 'Communication research registry express sign up notification failure')
            confirmation_message << ' We will send a reminder to your email address.'
          end
        elsif params[:contact] == 'phone'
          admin_notification = express_sign_up_phone_contact_text(params[:name], params[:phone])
          admin_email(admin_notification, 'Communication research registry express sign up notification')
          confirmation_message << ' We will call you within two business days.'
        end
        flash['notice'] = confirmation_message
        format.html { redirect_to public_login_path(anchor: 'express_sign_up') }
      else
        flash['error'] = errors.to_sentence
        format.html { redirect_to public_login_path(anchor: 'express_sign_up', contact: params[:contact], name: params[:name], email: params[:email]) }
      end
    end
  end

  private
    def set_account
      @account = Account.find(params[:id])
    end

    def account_params
      params.require(:account).permit(:email, :password, :password_confirmation)
    end

    def express_signup_validation_errors(params)
      errors = []
      errors << 'Name can\'t be blank'              if params[:name].blank?
      errors << 'Preferred contact can\'t be blank' if params[:contact].blank?

      email_contact = params[:contact] == 'email'
      phone_contact = params[:contact] == 'phone'
      errors << 'Email can\'t be blank' if params[:email].blank? && email_contact
      errors << 'Email is invalid'      if params[:email].present? && params[:email] !~ /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/i
      errors << 'Phone can\'t be blank' if params[:phone].blank? && phone_contact
      errors
    end

    def express_sign_up_email_contact_text(name, email)
      <<-emailtext
Dear User,

The following user requested to be contacted by email via the express sign up.
#{name}
#{email}
    emailtext
  end

    def express_sign_up_phone_contact_text(name, phone)
    <<-emailtext
Dear User,

The following user requested to be contacted by phone via the express sign up.
#{name}
#{phone}
    emailtext
    end
end
