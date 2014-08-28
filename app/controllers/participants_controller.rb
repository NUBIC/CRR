class ParticipantsController < PublicController
  before_filter :require_user

  def enroll
    begin
      @participant = Participant.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to dashboard_path
      return
    end
    authorize! :enroll, @participant
    if current_user.active_participants.size > 0
      @participant.copy_from(current_user.copy_from_participant(@participant))
      @participant.save
    end
    @participant.related_participants.each do |destination|
      @participant.origin_relationships.build(destination_id: destination.id)
    end

    if @participant.survey?
      @participant.recent_response_set ?
        redirect_to(edit_response_set_path(@participant.recent_response_set)) : create_and_redirect_response_set(@participant)
    elsif @participant.consent_denied?
      redirect_to dashboard_path
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
    # authorize! :create, @participant
    account_participant.proxy = true if params[:proxy] == "true"
    if account_participant.save
      if params[:child] == "true"
        @participant.child = true
        @participant.save
      end
      if current_user.active_participants.size > 0
        @participant.copy_from(current_user.copy_from_participant(@participant))
        @participant.save
      end
    else
      flash[:error] = account_participant.errors
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
    @participant.update_attributes(participant_relationship_params)
    if @participant.save
      @participant.take_survey! if @participant.demographics?
    else
      flash[:error] = @participant.errors.full_messages.to_sentence
    end

    #ToDo : Remove after testing
    sleep(10)
    @participant.survey? ? create_and_redirect_response_set(@participant) : redirect_to(enroll_participant_path(@participant))
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
    params.require(:participant).permit(:first_name, :last_name, :address_line1, :address_line2, :city, :state,
      :zip, :primary_phone, :secondary_phone, :email, :primary_guardian_first_name, :primary_guardian_last_name,
      :primary_guardian_email, :primary_guardian_phone, :secondary_guardian_first_name, :secondary_guardian_last_name,
      :secondary_guardian_email, :secondary_guardian_phone, :hear_about_registry)
  end

  def account_params
    params.require(:participant).permit(:child, :account_id)
  end

  def participant_relationship_params
    params.require(:participant).permit(origin_relationships_attributes: [:id, :category, :destination_id, :_destroy])
  end

  def consent_signature_params
    params.require(:consent_signature).permit(:date, :consent_id, :proxy_name, :proxy_relationship)
  end

  private
  def create_and_redirect_response_set(participant)
    response_set = participant.create_response_set(participant.child_proxy? ? Survey.child_survey : Survey.adult_survey)
    redirect_to(edit_response_set_path(response_set))
  end
end
