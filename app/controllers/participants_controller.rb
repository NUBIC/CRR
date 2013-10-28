class ParticipantsController < ApplicationController

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

  # def create
  #   @participant = Participant.new(participant_params)
  #   if @participant.save
  #     flash[:notice] = "Successfully created"
  #   else
  #     flash[:error] = @participant.errors.full_messages.to_sentence
  #   end
  #   redirect_to participants_path
  # end

  def create
    @account = Account.find(params[:account_id])
    @participant = Participant.create!
    account_participant = AccountParticipant.new(:participant => @participant, :account => @account)
    if params[:proxy] == true
      account_participant.proxy = true
      account_participant.save!
    end
    redirect_to dashboard_path
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
      flash[:notice] = "Successfully updated"
    else
      flash[:error] = @participant.errors.full_messages.to_sentence
    end
    redirect_to @participant
  end

 def participant_params
   params.require(:participant).permit(:first_name, :last_name,:middle_name,:address_line1,:address_line2,:city,:state,:zip,:primary_phone,:secondary_phone,:email,:notes,:do_not_contact)
 end
end
