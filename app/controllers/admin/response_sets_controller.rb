class Admin::ResponseSetsController < Admin::AdminController
  before_action :set_response_set, only: [:show, :edit, :update, :destroy, :load_from_file, :download]

  def index
    authorize ResponseSet
    @participant = Participant.find(params[:participant_id])
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def new
    @participant  = Participant.find(params[:participant_id])
    @response_set = @participant.response_sets.new
    authorize @response_set
    @surveys = Survey.all.select{|s| s.active?}
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  def create
    @response_set = ResponseSet.new(response_set_params)
    authorize @response_set

    @participant = @response_set.participant
    saved = @response_set.save
    unless saved
      flash['error'] = @response_set.errors.full_messages.to_sentence
      @surveys = Survey.all.select{|s| s.active?}
    end
    respond_to do |format|
      # format.js{ render (saved ? (@response_set.public? ? admin_participant_path(@response_set.participant, tab: "surveys") : :edit) : :new), layout: false}
      format.html{ saved ? @response_set.public? ? redirect_to(admin_participant_path(@response_set.participant, tab: 'surveys')) : redirect_to(edit_admin_response_set_path(@response_set.reload)) : render(action: :new)}
    end
  end

  def edit
    authorize @response_set
    @survey = @response_set.survey
    @section = @survey.sections.find_by_id(params[:section_id]).nil? ? @survey.sections.first : @survey.sections.find_by_id(params[:section_id])
  end

  def update
    authorize @response_set
    @survey = @response_set.survey
    @response_set.update_attributes(response_set_params)
    finish = params[:button].eql?('finish')

    unless @response_set.save && (!finish || finish && @response_set.reload.complete!)
      flash['error'] = @response_set.errors.full_messages.flatten.uniq.compact.to_sentence +  @response_set.responses.collect{|r| r.errors.full_messages}.flatten.uniq.compact.to_sentence
    end

    if finish && flash['error'].blank?
      respond_to do |format|
        format.html { redirect_to admin_participant_path(@response_set.participant, tab: 'surveys') }
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_admin_response_set_path(@response_set.reload) }
        format.js   { render :edit, layout: false }
      end
    end
  end

  def destroy
    authorize @response_set
    @participant = @response_set.participant
    @response_set.destroy
    redirect_to admin_participant_path(@participant, tab: 'surveys')
  end

  def load_from_file
    authorize @response_set
    @response_set.load_from_file(params[:import_file])
    if @response_set.errors.any?
      flash['error'] = @response_set.errors.full_messages.uniq.join('<br/>').html_safe
      @response_set.errors.clear
    end
    render :edit
  end

  def download
    authorize @response_set

    question = @response_set.survey.questions.find(params[:question_id])               if params[:question_id].present?
    response = @response_set.responses.detect{|res| res.question_id.eql?(question.id)} if question.present?

    if response.present? && response.file_upload.present?
      return send_file response.file_upload.path, disposition: 'attachment', x_sendfile: true
    else
      flash['error'] = 'Could not locate the file'
      redirect_to edit_admin_response_set_path(@response_set.reload)
    end
  end

  private
    def set_response_set
      @response_set = ResponseSet.find(params[:id])
    end

    def response_set_params
      params.fetch(:response_set, {}).permit!
    end
end
