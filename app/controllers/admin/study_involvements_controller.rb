class Admin::StudyInvolvementsController < Admin::AdminController
  before_action :set_study_involvment, only: [:edit, :update, :destroy]

  def new
    @participant = Participant.find(params[:participant_id])
    @study_involvement = @participant.study_involvements.new
    @study_involvement.build_study_involvement_status
    authorize @study_involvement
  end

  def create
    @study_involvement = StudyInvolvement.new(study_involvment_params)
    authorize @study_involvement

    @participant = @study_involvement.participant
    if @study_involvement.save
     redirect_to admin_participant_path(@participant)
    else
     flash['error'] = @study_involvement.errors.full_messages.to_sentence
     redirect_to new_admin_study_involvement_path(participant_id: @participant.id)
    end
  end

  def edit
    authorize @study_involvement
    @participant = @study_involvement.participant
    @study_involvement.build_study_involvement_status unless @study_involvement.study_involvement_status
  end

  def update
    authorize @study_involvement
    @study_involvement.update_attributes(study_involvment_params)
    @participant = @study_involvement.participant
    if @study_involvement.save
     redirect_to admin_participant_path(@participant)
    else
     flash['error'] = @study_involvement.errors.full_messages.to_sentence
     redirect_to edit_admin_study_involvement_path(@study_involvement)
    end
  end

  def destroy
    authorize @study_involvement
    @participant = @study_involvement.participant
    @study_involvement.destroy
    redirect_to admin_participant_path(@participant)
  end

  private
    def set_study_involvment
      @study_involvement = StudyInvolvement.find(params[:id])
    end

    def study_involvment_params
      params.require(:study_involvement).permit(:participant_id, :study_id, :notes, :start_date, :end_date, :warning_date, :state, :state_date, study_involvement_status_attributes: [:name, :date, :state])
    end
end
