class Admin::EmailNotificationsController < Admin::AdminController
  before_action :set_email_notification, except: :index

  def index
    @email_notifications = EmailNotification.order(:name).all
    authorize EmailNotification
  end

  def show
    authorize @email_notification
  end

  def edit
    authorize @email_notification
    @email_notification.deactivate
    @email_notification.save
  end

  def update
    authorize @email_notification
    @email_notification.update_attributes(email_notification_params)
    if @email_notification.save
      flash['notice'] = 'Updated'
    else
      flash['error'] = @email_notification.errors.full_messages.to_sentence
    end
    redirect_to admin_email_notifications_path
  end

  def deactivate
    authorize @email_notification
    @email_notification.deactivate
    if @email_notification.save
      flash['notice'] = 'Deactivated'
    else
      flash['error'] = @email_notification.errors.full_messages.to_sentence
    end
    redirect_to admin_email_notifications_path
  end

  def activate
    authorize @email_notification
    @email_notification.activate
    if @email_notification.save
      flash['notice'] = 'Activated'
    else
      flash['error'] = @email_notification.errors.full_messages.to_sentence
    end
    redirect_to admin_email_notifications_path
  end

  private
    def set_email_notification
      @email_notification = EmailNotification.find(params[:id])
    end

    def email_notification_params
      params.require(:email_notification).permit(:content, :state)
    end
end
