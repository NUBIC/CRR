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

  def edit
    @account = Account.find(params[:id])
    authorize! :edit, @account
  end

  def create
    @account = Account.new(account_params)
    respond_to do |format|
      if @account.save
        format.html { redirect_to dashboard_path }
        welcome_email = EmailNotification.active.find_by(email_type: 'Welcome')
        EmailNotificationsMailer.generic_email(@account.email, welcome_email.content, 'Welcome to the communication research registry.').deliver! if welcome_email
      else
        format.html { redirect_to public_login_path(anchor: 'sign_up')
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
          format.html { render action: 'edit' }
        end
      end
    else
      respond_to do |format|
        flash[:error] = 'Current password doesn\'t match. Please try again.'
        format.html { render action: 'edit' }
      end
    end
  end

  def express_sign_up
    errors = []
    errors << 'Name can\'t be blank' if params[:name].blank?
    errors << 'Preferred contact can\'t be blank' if params[:contact].blank?

    email_contact = params[:contact] == 'email'
    phone_contact = params[:contact] == 'phone'
    errors << 'Email can\'t be blank' if params[:email].blank? && email_contact
    errors << 'Email is invalid' if !params[:email].blank? && params[:email] !~ /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/i
    errors << 'Phone can\'t be blank' if params[:phone].blank? && phone_contact


    respond_to do |format|
      if errors.empty?
        confirmation_message = 'Thank you for your interest in the Communication Research Registry.'
        if email_contact
          admin_notification = <<-emailtext
            Dear User,
            The following user requested to be contacted by email via the express sign up.
            #{params[:name]}
            #{params[:email]}

          emailtext
          express_sign_up_email = EmailNotification.active.find_by(email_type: 'Express sign up')
          if express_sign_up_email
            EmailNotificationsMailer.generic_email(params[:email], express_sign_up_email.content, 'Welcome to the communication research registry.').deliver!
            confirmation_message << ' We have sent a reminder to your email address.'
          else
            admin_notification << 'ATTENTION: Notification email message could not be sent (corresponding email could have been deactivated)'
            confirmation_message << ' We will send a reminder to your email address.'
          end
          EmailNotificationsMailer.generic_email(params[:email], admin_notification, 'Communication research registry express sign up notification').deliver!
        elsif phone_contact
          admin_notification = <<-emailtext
            Dear User,
            The following user requested to be contacted by phone via the express sign up.
            #{params[:name]}
            #{params[:phone]}
          emailtext
          EmailNotificationsMailer.generic_email(Rails.configuration.custom.app_config['contact_email'], admin_notification, 'Communication research registry express sign up notification').deliver!
          confirmation_message << ' We will call you within two business days.'
        end
        flash[:notice] = confirmation_message
        format.html { redirect_to public_login_path }
      else
        flash[:error] = errors.to_sentence
        format.html { redirect_to public_login_path(anchor: 'express_sign_up', contact: params[:contact], name: params[:name], email: params[:email]) }
      end
    end
  end
  def account_params
    params.require(:account).permit(:email, :password, :password_confirmation)
  end
end
