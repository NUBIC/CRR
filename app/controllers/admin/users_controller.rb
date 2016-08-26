class Admin::UsersController < Admin::AdminController
  include EmailNotifications

  before_action :set_user, only: [:edit, :update, :destroy, :activate, :deactivate]

  def index
    authorize User
    if params[:state]
      @state = params[:state]
    else
      @state = 'active'
    end

    @users = User.by_state(@state)
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user

    if @user.save
      flash['notice'] = 'Created'
      if @user.researcher?
        welcome_email = EmailNotification.active.welcome_researcher
        if welcome_email
          outbound_email(@user.email, welcome_email.content, welcome_email.subject)
        else
          flash['error'] = 'ATTENTION: Notification email message could not be sent (corresponding email could have been deactivated)'
        end
      end
    else
      flash['error'] = @user.errors.full_messages.to_sentence
    end
    redirect_to admin_users_path
  end

  def edit
    authorize @user
  end

  def update
    authorize @user

    @user.update_attributes(user_params)
    if @user.save
      flash['notice'] = 'Updated'
    else
      flash['error'] = @user.errors.full_messages.to_sentence
    end
    redirect_to admin_users_path
  end

  def destroy
    authorize @user
    @user.destroy
    redirect_to admin_users_path
  end

  def dashboard
    authorize User
    redirect_to admin_participants_path if policy(Participant).index?
  end

  def activate
    authorize @user
    @user.activate
    if @user.save
      flash['notice'] = 'Successfully activated'
    else
      flash['error'] = @user.errors.full_messages.to_sentence
    end
    redirect_to admin_users_path
  end

  def deactivate
    authorize @user
    @user.deactivate
    if @user.save(validate: false)
      flash['notice'] = 'Successfully Deactivated'
    else
      flash['error'] = @user.errors.full_messages.to_sentence
    end
    redirect_to admin_users_path
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:netid,:researcher,:admin,:data_manager,:study_tokens)
    end
end

