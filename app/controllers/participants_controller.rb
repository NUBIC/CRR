class ParticipantsController < ApplicationController
  def index
    @participants = Participant.all
  end

  def new
    @participant = Participant.new
  end

  def create
    @participant = Participant.new(participant_params)
    if @participant.save
      flash[:notice] = "Successfully created"
    else
      flash[:error] = @participant.errors.full_messages.to_sentence
    end
    redirect_to participants_path
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
    @participant.attributes = params[:participant]
    if @participant.save
      flash[:notice] = "Successfully updated"
    else
      flash[:error] = @participant.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.html
      format.js {render :layout=>false}
    end
  end

 def participant_params
   params.require(:participant).permit(:first_name, :last_name,:middle_name)
 end
end
