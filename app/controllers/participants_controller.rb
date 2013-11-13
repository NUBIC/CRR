class ParticipantsController < PublicController
  before_filter :require_account


  def enroll
    @participant = Participant.find(params[:id])
    if @participant.consented?
      @survey = @participant.child_proxy? ? Survey.child_survey : Survey.adult_survey
    end
  end

  def search
    @participants = Participant.search(params[:q])
    respond_to do |format|
      format.json {render :json => @participants.to_json(:only=>[:id],:methods=>[:search_display])}
    end
  end


  def new
    @participant = Participant.new
  end

  def create
    @account = Account.find(params[:account_id])
    @participant = Participant.create!
    account_participant = AccountParticipant.new(:participant => @participant, :account => @account)
    account_participant.proxy = true if params[:proxy] == "true"
    account_participant.save
    if params[:child] == "true"
      @participant.child = true
      @participant.save
    end
    redirect_to enroll_participant_path(@participant)
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
    if participant_relationship_params[:relationships]
      participant_relationship_params[:relationships].each_value do |relationship_params|
        @participant.origin_relationships.create( :category => relationship_params[:category],
                                                  :destination_id => relationship_params[:destination_id])
      end
    end
    if @participant.save
      @participant.take_survey! if @participant.demographics?
      flash[:notice] = "Successfully updated"
    else
      flash[:error] = @participant.errors.full_messages.to_sentence
    end
    redirect_to enroll_participant_path(@participant)
  end

  def consent_signature
    @participant = Participant.find(params[:id])
    params[:consent_response] == 'accept' ? @participant.sign_consent!(nil, params[:consent_name]) : @participant.decline_consent!
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
end
