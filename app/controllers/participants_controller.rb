class ParticipantsController < ApplicationController
  def enroll
    @participant = Participant.find(params[:id])
    @survey = Survey.all.select {|s| s.adult_survey? }.first
  end

  def search
    @participants = Participant.search(params[:q])
    respond_to do |format|
      format.json {render :json => @participants.to_json(:only=>[:id],:methods=>[:search_display])}
    end
  end
  
  def index
    @participants = Participant.all
  end

  def new
    @participant = Participant.new
  end

  def create
    @account = Account.find(params[:account_id])
    @participant = Participant.create!
    account_participant = AccountParticipant.new(:participant => @participant, :account => @account)
    account_participant.proxy = true if params[:proxy] == true
    account_participant.save!
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
    params[:consent_response] == 'accept' ? @participant.sign_consent! : @participant.decline_consent!
    respond_to do |format|
      format.html { redirect_to enroll_participant_path(@participant) }
    end
  end

  def participant_params
    params.require(:participant).permit(:first_name, :last_name,:middle_name,:address_line1,:address_line2,:city,:state,:zip,:primary_phone,:secondary_phone,:email,:notes,:do_not_contact)
  end
end
