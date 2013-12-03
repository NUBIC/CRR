class ParticipantsController < PublicController
  # before_filter :require_account
  def enroll
    @participant = Participant.find(params[:id])
    authorize! :enroll, @participant
    if @participant.survey?
      create_and_redirect_response_set(@participant)
    elsif @participant.survey_started?
      redirect_to(edit_response_set_path(@participant.recent_response_set))
    end
  end

  def consent
    @participant = Participant.find(params[:id])
    authorize! :consent , @participant
  end

  def search
    @participants = Participant.search(params[:q])
    respond_to do |format|
      format.json {render :json => @participants.to_json(:only=>[:id],:methods=>[:search_display])}
    end
  end

  def create
    @account = Account.find(params[:account_id])
    @participant = Participant.create!
    account_participant = AccountParticipant.new(:participant => @participant, :account => @account)
    authorize! :create, @participant
    account_participant.proxy = true if params[:proxy] == "true"
    account_participant.save
    if params[:child] == "true"
      @participant.child = true
      @participant.save
    end
    if @account.other_participants(@participant).size > 0
      @participant.copy_from(@account.other_participants(@participant).last)
      @participant.save
    end
    redirect_to enroll_participant_path(@participant)
  end

  def show
    @participant = Participant.find(params[:id])
    authorize! :show, @participant
  end

  def update
    @participant =  Participant.find(params[:id])
    authorize! :update, @participant
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
    authorize! :consent_signature, @participant
    params[:consent_response] == 'accept' ? @participant.sign_consent!(nil,consent_signature_params) : @participant.decline_consent!
    respond_to do |format|
      format.html { redirect_to enroll_participant_path(@participant) }
    end
  end

  def participant_params
    params.require(:participant).permit(:first_name, :last_name, :middle_name, :address_line1, :address_line2, :city, :state,
      :zip, :primary_phone, :secondary_phone, :email, :primary_guardian_first_name, :primary_guardian_last_name,
      :primary_guardian_email, :primary_guardian_phone, :secondary_guardian_first_name, :secondary_guardian_last_name,
      :secondary_guardian_email, :secondary_guardian_phone)
  end

  def participant_relationship_params
    params.require(:participant).permit(relationships: [ :category, :destination_id ])
  end

  def consent_signature_params
    params.require(:consent_signature).permit(:date,:consent_id,:proxy_name)
  end
  private
  def create_and_redirect_response_set(participant)
    response_set = participant.create_response_set(participant.child_proxy? ? Survey.child_survey : Survey.adult_survey)
    participant.start_survey!
    redirect_to(edit_response_set_path(response_set))
  end
end
