class Admin::ParticipantsController < Admin::AdminController

  def index
    @participants = params[:state].blank? ? Participant.all_participants : Participant.send(params[:state])
  end

  def enroll
    @participant = Participant.find(params[:id])
    authorize! :enroll, @participant
    if @participant.survey?
      create_and_redirect_response_set(@participant) unless @participant.recent_response_set
      redirect_to(edit_response_set_path(@participant.recent_response_set))
    end
  end

  def new
    @participant = Participant.new
    authorize! :new, @participant
  end

  def consent
    @participant = Participant.find(params[:id])
    authorize! :consent, @participant
  end

  def search
    @participants = Participant.search(params[:q])
    authorize! :search, Participant
    respond_to do |format|
      format.json {render :json => @participants.to_json(:only=>[:id],:methods=>[:search_display])}
    end
  end

  def create
    @participant = Participant.new(participant_params)
    authorize! :create, @participant
    @participant.save
    redirect_to enroll_admin_participant_path(@participant)
  end

  def show
    @participant = Participant.find(params[:id])
    authorize! :show, @participant
  end

  def edit
    @participant = Participant.find(params[:id])
    authorize! :edit, @participant
    respond_to do |format|
      format.html
      format.js {render :layout=>false}
    end
  end

  def update
    @participant =  Participant.find(params[:id])
    authorize! :update, @participant
    @participant.update_attributes(participant_params)
    if @participant.save
      @participant.take_survey! if @participant.demographics?
      if @participant.survey?
        create_and_redirect_response_set(@participant)
      else
        redirect_to admin_participant_path(@participant)
      end
    else
      flash[:error] = @participant.errors.full_messages.to_sentence
      redirect_to admin_participant_path(@participant)
    end

  end

  def consent_signature
    @participant = Participant.find(params[:id])
    authorize! :consent_signature, @participant
    @participant.sign_consent!(nil, consent_signature_params)
    respond_to do |format|
      format.html { redirect_to enroll_admin_participant_path(@participant) }
    end
  end

  def withdraw
    @participant = Participant.find(params[:id])
    authorize! :withdraw, @participant
    @participant.withdraw!
    redirect_to admin_participants_path
  end

  def verify
    @participant = Participant.find(params[:id])
    authorize! :verify, @participant
    @participant.verify!
    redirect_to admin_participant_path(@participant)
  end

  def participant_params
    params.require(:participant).permit(:child,:first_name, :last_name, :address_line1, :address_line2, :city, :state,
      :zip, :primary_phone, :secondary_phone, :email, :primary_guardian_first_name, :primary_guardian_last_name,
      :primary_guardian_email, :primary_guardian_phone, :secondary_guardian_first_name, :secondary_guardian_last_name,
      :secondary_guardian_email, :secondary_guardian_phone, :notes, :do_not_contact, :hear_about_registry)
  end

  def participant_relationship_params
    params.require(:participant).permit(relationships: [ :category, :destination_id ])
  end

  def consent_signature_params
    params.require(:consent_signature).permit(:date, :consent_id, :proxy_name, :proxy_relationship)
  end

  private
  def create_and_redirect_response_set(participant)
    response_set = participant.create_response_set(participant.child? ? Survey.child_survey : Survey.adult_survey)
    redirect_to(edit_admin_response_set_path(response_set))
  end
end
