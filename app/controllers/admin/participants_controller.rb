class Admin::ParticipantsController < Admin::AdminController

  def index
    @participants = params[:state].blank? ? [] : Participant.send(params[:state])
  end

  def enroll
    @participant = Participant.find(params[:id])
    if @participant.survey?
      create_and_redirect_response_set(@participant)
    elsif @participant.survey_started?
      redirect_to(edit_response_set_path(@participant.recent_response_set))
    end
  end

  def new
    @participant = Participant.new
  end

  def consent
    @participant = Participant.find(params[:id])
  end

  def search
    @participants = Participant.search(params[:q])
    respond_to do |format|
      format.json {render :json => @participants.to_json(:only=>[:id],:methods=>[:search_display])}
    end
  end

  def create
    @participant = Participant.new(participant_params)
    @participant.save
    redirect_to enroll_admin_participant_path(@participant)
  end

  def show
    @participant = Participant.find(params[:id])
  end

  def edit
    @participant = Participant.find(params[:id])
    respond_to do |format|
      format.html
      format.js {render :layout=>false}
    end
  end

  def update
    @participant =  Participant.find(params[:id])
    @participant.update_attributes(participant_params)
    if @participant.save
      if participant_relationship_params[:relationships]
        participant_relationship_params[:relationships].each_value do |relationship_params|
          @participant.origin_relationships.create( :category => relationship_params[:category],
                                                  :destination_id => relationship_params[:destination_id])
        end
      end
      @participant.take_survey! if @participant.demographics?
      if @participant.survey?
        create_and_redirect_response_set(@participant)
      else
        redirect_to enroll_participant_path(@participant)
      end
    else
      flash[:error] = @participant.errors.full_messages.to_sentence
      redirect_to enroll_participant_path(@participant)
    end

  end

  def consent_signature
    @participant = Participant.find(params[:id])
    params[:consent_response] == 'accept' ? @participant.sign_consent!(nil, params[:consent_name]) : @participant.decline_consent!
    respond_to do |format|
      format.html { redirect_to enroll_participant_path(@participant) }
    end
  end

  def withdraw
    @participant = Participant.find(params[:id])
    @participant.withdraw!
    redirect_to admin_participants_path
  end

  def verify
    @participant = Participant.find(params[:id])
    @participant.verify!
    redirect_to admin_participant_path(@participant)
  end

  def participant_params
    params.require(:participant).permit(:child,:first_name, :last_name, :middle_name, :address_line1, :address_line2, :city, :state,
      :zip, :primary_phone, :secondary_phone, :email, :primary_guardian_first_name, :primary_guardian_last_name,
      :primary_guardian_email, :primary_guardian_phone, :secondary_guardian_first_name, :secondary_guardian_last_name,
      :secondary_guardian_email, :secondary_guardian_phone)
  end

  def participant_relationship_params
    params.require(:participant).permit(relationships: [ :category, :destination_id ])
  end

  private
  def create_and_redirect_response_set(participant)
    response_set = participant.create_response_set(participant.child_proxy? ? Survey.child_survey : Survey.adult_survey)
    participant.start_survey!
    redirect_to(edit_response_set_path(response_set))
  end
end
