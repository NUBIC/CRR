class Admin::StudyInvolvementsController < Admin::AdminController
 def index
   @participant = Participant.find(params[:participant_id])
 end

 def study
   @study = Study.find(params[:study_id])
   @study_involvements = params[:state].eql?('active') ? @study.study_involvements.active : @study.study_involvements
   respond_to do |format|
     format.js {render :layout => false}
   end
 end

 def new
   @participant = Participant.find(params[:participant_id])
   @study_involvement = @participant.study_involvements.new
 end

 def edit
   @study_involvement = StudyInvolvement.find(params[:id])
 end

 def update
   @study_involvement = StudyInvolvement.find(params[:id])
   @study_involvement.update_attributes(si_params)
   @participant = @study_involvement.participant
   if @study_involvement.save
    redirect_to admin_participant_path(@participant,:tab=>'studies')
   else
    flash[:notice]=@study_involvement.errors.full_messages.to_sentence
    redirect_to edit_admin_study_involvement_path(@study_involvement)
   end
 end
 def create
   @study_involvement = StudyInvolvement.new(si_params)
   @participant = @study_involvement.participant
   if @study_involvement.save
    redirect_to admin_participant_path(@participant,:tab=>'studies')
   else
    flash[:notice]=@study_involvement.errors.full_messages.to_sentence
    redirect_to new_admin_study_involvement_path(participant_id: @participant.id)
   end
 end
 def destroy
   @study_involvement = StudyInvolvement.find(params[:id])
   @study_involvement.destroy
 end

 def si_params
   params.require(:study_involvement).permit(:participant_id,:study_id,:notes,:start_date,:end_date,:warning_date,:state,:state_date)
 end
end

