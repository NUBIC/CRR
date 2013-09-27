class ContactLogsController < ApplicationController
 def index
   @participant = Participant.find(params[:participant_id])
 end

 def new
   @participant = Participant.find(params[:participant_id])
   @contact_log = @participant.contact_logs.new
 end

 def edit
   @contact_log = ContactLog.find(params[:id])
 end

 def update
   @contact_log = ContactLog.find(params[:id])
   @participant = @contact_log.participant
   @contact_log.update_attributes(cl_params)
   if @contact_log.save
     flash[:notice]="Updated study association"
   else
     flash[:notice]=@contact_log.errors.full_messages.to_sentence
   end
    respond_to do |format|
      format.js {render :index,:layout => false}
    end
 end
 def create
   @contact_log = ContactLog.new(cl_params)
   if @contact_log.save
     flash[:notice]="Added new study association"
   else
     flash[:notice]=@contact_log.errors.full_messages.to_sentence
   end
   @participant = @contact_log.participant
    respond_to do |format|
      format.js {render :index,:layout => false}
    end
 end
 def destroy
   @contact_log = ContactLog.find(params[:id])
   @contact_log.destroy
 end

 def cl_params
   params.require(:contact_log).permit(:participant_id,:date,:notes)
 end
end


