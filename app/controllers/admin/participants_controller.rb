require './lib/csv_exporter/participant'

class Admin::ParticipantsController < Admin::AdminController
  before_action :set_participant, only: [
    :show, :edit, :update, :enroll, :consent, :consent_signature, :withdraw, :verify, :suspend
  ]

  def index
    authorize Participant
    respond_to do |format|
      format.html do
        participants = Participant.includes(
          :account,
          response_sets: { survey: :sections},
          study_involvements: [:study_involvement_status, :study]
        )
        @participants = params[:state].blank? ? participants.all_participants : participants.by_stage(params[:state])
      end
      format.csv do
        participants = Participant.approved
        filename = "crr_approved_participants_#{Date.today.strftime('%m_%d_%Y')}"
        response.headers['Content-Type']              = 'text/csv'
        response.headers['Content-Disposition']       = "attachment; filename=\"#{filename}.csv\""
        response.headers['Content-Transfer-Encoding'] = 'binary'
        response.headers['Last-Modified']             = Time.now.ctime.to_s
        self.response_body = CSVExporter::Participant.new(
          participants: participants,
          participant_export_params:  participant_export_params,
          survey_export_params:       survey_export_params.to_h,
          section_export_params:      section_export_params.to_h,
          question_export_params:     question_export_params.to_h
        )
      end
    end
  end

  def new
    @participant = Participant.new
    authorize @participant
  end

  def create
    @participant = Participant.new(participant_params)
    authorize @participant
    if @participant.save
      redirect_to enroll_admin_participant_path(@participant)
    else
      flash['error'] = @participant.errors.full_messages.to_sentence
      render :new
    end
  end

  def show
    authorize @participant
  end

  def edit
    authorize @participant
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  def update
    authorize @participant
    @participant.update_attributes(participant_params)
    if @participant.save
      @participant.take_survey! if @participant.demographics?
      if @participant.survey?
        create_and_redirect_response_set(@participant)
      else
        redirect_to admin_participant_path(@participant)
      end
    else
      flash['error'] = @participant.errors.full_messages.to_sentence
      render :edit
    end
  end

  def global
    authorize Participant
    @participants = Participant.includes(:origin_relationships, :destination_relationships, :account).where.not(stage: Participant::INACTIVE_STAGES)
  end

  def enroll
    authorize @participant
    if @participant.survey?
      if @participant.recent_response_set
        redirect_to(edit_response_set_path(@participant.recent_response_set))
      else
        create_and_redirect_response_set(@participant)
      end
    end
  end

  def consent_signature
    authorize @participant
    @participant.sign_consent!(nil, consent_signature_params)
    respond_to do |format|
      format.html { redirect_to enroll_admin_participant_path(@participant) }
    end
  end

  def withdraw
    authorize @participant
    @participant.withdraw!
    redirect_to admin_participants_path
  end

  def suspend
    authorize @participant
    @participant.suspend!
    redirect_to admin_participants_path
  end

  def verify
    authorize @participant
    @participant.verify!
    redirect_to admin_participant_path(@participant)
  end

  def search
    authorize Participant
    @participants = Participant.search(params[:q])
    respond_to do |format|
      format.json {render json: @participants.to_json(only: [:id],methods: [:search_display])}
    end
  end

  def export
    authorize Participant
  end

  private
    def set_participant
      @participant = Participant.find(params[:id])
    end

    def participant_params
      params.require(:participant).permit(:child,:first_name, :last_name, :address_line1, :address_line2, :city, :state,
        :zip, :primary_phone, :secondary_phone, :email, :primary_guardian_first_name, :primary_guardian_last_name,
        :primary_guardian_email, :primary_guardian_phone, :secondary_guardian_first_name, :secondary_guardian_last_name,
        :secondary_guardian_email, :secondary_guardian_phone, :notes, :do_not_contact, :hear_about_registry)
    end

    def participant_relationship_params
      params.require(:participant).permit(relationships: [ :category, :destination_id ])
    end

    def consent_signature_params
      params.require(:consent_signature).permit(:date, :consent_id, :proxy_name, :proxy_relationship)
    end

    def create_and_redirect_response_set(participant)
      response_set = participant.create_response_set(participant.child? ? Survey.child_survey : Survey.adult_survey)
      redirect_to(edit_admin_response_set_path(response_set))
    end

    def participant_export_params
      params.require(:participant).permit(
        :id,
        :first_name,
        :last_name,
        :studies,
        :join_date,
        :account_email,
        :tier_2,
        :contact_information,
        :source,
        :relationships
      )
    end

    def survey_export_params
      params.fetch(:survey, {}).permit(id: [])
    end

    def section_export_params
      params.fetch(:section, {}).permit(id: [])
    end

    def question_export_params
      params.fetch(:question, {}).permit(id: [])
    end
end
