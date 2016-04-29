class ParticipantsController < PublicController
  before_action :require_user
  before_action :set_participant, only: [:show, :update, :enroll, :consent, :consent_signature]

  def create
    @account = Account.where(id: params[:account_id]).first
    raise Pundit::NotAuthorizedError if @account.nil?
    authorize Participant

    @participant = Participant.new( child: params[:child] == 'true')
    account_participant = AccountParticipant.new( participant: @participant, account: @account, proxy: params[:proxy] == 'true')
    respond_to do |format|
      if account_participant.save
        if current_user.active_participants.any?
          @participant.copy_from(current_user.copy_from_participant(@participant))
          @participant.save
        end
        format.html { redirect_to enroll_participant_path(@participant) }
      else
        flash['error'] = account_participant.errors
        format.html { redirect_to dashboard_path }
      end
    end
  end

  def show
    authorize @participant
  end

  def update
    authorize @participant

    @participant.update_attributes(participant_params)
    @participant.update_attributes(participant_relationship_params)
    if @participant.save
      @participant.take_survey! if @participant.demographics?
    else
      flash['error'] = @participant.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.html { @participant.survey? ? create_and_redirect_response_set(@participant) : redirect_to(enroll_participant_path(@participant)) }
    end
  end

  def enroll
    authorize @participant

    if current_user.active_participants.size > 0
      @participant.copy_from(current_user.copy_from_participant(@participant))
      @participant.save
    end

    @participant.related_participants.each do |destination|
      @participant.origin_relationships.build(destination_id: destination.id)
    end
    if @participant.survey?
      respond_to do |format|
        format.html {  @participant.recent_response_set.blank? ? create_and_redirect_response_set(@participant) : redirect_to(edit_response_set_path(@participant.recent_response_set)) }
      end
    elsif @participant.consent_denied?
      respond_to do |format|
        format.html { redirect_to dashboard_path }
      end
    end
  end

  def consent
    authorize @participant
  end

  def consent_signature
    authorize @participant

    if params[:consent_response] != 'accept'
      @participant.decline_consent!
    else
      @participant.consent_signatures.build(consent_signature_params)
      unless @participant.save && @participant.sign_consent!
        flash['error'] = @participant.errors.full_messages
      end
    end
    respond_to do |format|
      format.html { redirect_to enroll_participant_path(@participant) }
    end
  end

  private
    def participant_params
      params.require(:participant).permit(:first_name, :last_name, :address_line1, :address_line2, :city, :state,
        :zip, :primary_phone, :secondary_phone, :email, :primary_guardian_first_name, :primary_guardian_last_name,
        :primary_guardian_email, :primary_guardian_phone, :secondary_guardian_first_name, :secondary_guardian_last_name,
        :secondary_guardian_email, :secondary_guardian_phone, :hear_about_registry)
    end

    def participant_relationship_params
      params.require(:participant).permit(origin_relationships_attributes: [:id, :category, :destination_id, :_destroy])
    end

    def consent_signature_params
      params.require(:consent_signature).permit(:date, :consent_id, :proxy_name, :proxy_relationship)
    end

    def create_and_redirect_response_set(participant)
      response_set = participant.create_response_set(participant.child_proxy? ? Survey.child_survey : Survey.adult_survey)
      redirect_to(edit_response_set_path(response_set))
    end

    def set_participant
      @participant = Participant.where(id: params[:id]).first
      raise Pundit::NotAuthorizedError if @participant.nil?
    end
end
