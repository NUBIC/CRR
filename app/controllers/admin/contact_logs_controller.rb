class Admin::ContactLogsController < Admin::AdminController
  def index
    @participant = Participant.find(params[:participant_id])
  end

  def new
    @participant = Participant.find(params[:participant_id])
    @contact_log = @participant.contact_logs.new
    authorize! :new, @contact_log
  end

  def edit
    @contact_log = ContactLog.find(params[:id])
    @participant = @contact_log.participant
    authorize! :edit, @contact_log
  end

  def update
    @contact_log = ContactLog.find(params[:id])
    authorize! :update, @contact_log
    @participant = @contact_log.participant
    @contact_log.update_attributes(cl_params)
    if @contact_log.save
      redirect_to admin_participant_path(@participant)
    else
      flash[:notice]=@contact_log.errors.full_messages.to_sentence
      redirect_to edit_admin_contact_log_path(@contact_log)
    end
  end

  def create
    @contact_log = ContactLog.new(cl_params)
    @participant = @contact_log.participant
    authorize! :create, @contact_log
    if @contact_log.save
      redirect_to admin_participant_path(@participant)
    else
      flash[:notice]=@contact_log.errors.full_messages.to_sentence
      redirect_to new_admin_contact_log_path(participant_id: @participant.id)
    end
  end

  def destroy
    @contact_log = ContactLog.find(params[:id])
    @participant = @contact_log.participant
    authorize! :destroy, @contact_log
    @contact_log.destroy
    redirect_to admin_participant_path(@participant)
  end

  def cl_params
    params.require(:contact_log).permit(:participant_id, :date, :notes, :mode)
  end
end


