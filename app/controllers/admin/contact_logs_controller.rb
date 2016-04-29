class Admin::ContactLogsController < Admin::AdminController
  before_action :set_contact_log, only: [:edit, :update, :destroy]

  def new
    @participant = Participant.find(params[:participant_id])
    @contact_log = @participant.contact_logs.new
    authorize @contact_log
  end

  def create
    @contact_log = ContactLog.new(contact_log_params)
    authorize @contact_log

    @participant = @contact_log.participant
    if @contact_log.save
      redirect_to admin_participant_path(@participant)
    else
      flash['error'] = @contact_log.errors.full_messages.to_sentence
      redirect_to new_admin_contact_log_path(participant_id: @participant.id)
    end
  end

  def edit
    authorize @contact_log
    @participant = @contact_log.participant
  end

  def update
    authorize @contact_log
    @participant = @contact_log.participant
    @contact_log.update_attributes(contact_log_params)
    if @contact_log.save
      redirect_to admin_participant_path(@participant)
    else
      flash['error'] = @contact_log.errors.full_messages.to_sentence
      redirect_to edit_admin_contact_log_path(@contact_log)
    end
  end

  def destroy
    authorize @contact_log
    @participant = @contact_log.participant
    @contact_log.destroy
    redirect_to admin_participant_path(@participant)
  end

  private
    def set_contact_log
      @contact_log = ContactLog.find(params[:id])
    end

    def contact_log_params
      params.require(:contact_log).permit(:participant_id, :date, :notes, :mode)
    end
end


