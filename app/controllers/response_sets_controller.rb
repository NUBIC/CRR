class ResponseSetsController < PublicController
  before_action :require_user
  before_action :set_response_set, only: [:show, :edit, :update]

  def create
    participant   = Participant.find(params[:participant_id])
    raise Pundit::NotAuthorizedError if participant.nil?

    @response_set = participant.response_sets.new(response_set_params)
    authorize @response_set

    respond_to do |format|
      if @response_set.save
        format.html { redirect_to edit_response_set_path(@response_set) }
      else
        flash['notice'] = @response_set.errors.full_messages.to_sentence
        format.html { redirect_to enroll_participant_path(participant) }
      end
    end
  end

  def show
    authorize @response_set
    @survey = @response_set.survey
  end

  def edit
    authorize @response_set

    @survey = @response_set.survey
    @section = @survey.sections.find_by_id(params[:section_id]).nil? ? @survey.sections.first : @survey.sections.find_by_id(params[:section_id])

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def update
    authorize @response_set

    @survey = @response_set.survey
    @response_set.update_attributes(response_set_params)

    finish = params[:button].eql?('finish')

    # if !@response_set.save || finish && !@response_set.reload.complete!
    unless @response_set.save && (!finish || finish && @response_set.reload.complete!)
      flash['error'] = @response_set.errors.full_messages.flatten.uniq.compact.to_sentence + @response_set.responses.collect{|r| r.errors.full_messages}.flatten.uniq.compact.to_sentence
    end

    if finish && flash['error'].blank?
      respond_to do |format|
        format.html { redirect_to dashboard_path(participant_id: @response_set.participant) }
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_response_set_path(@response_set.reload) }
        format.js   { render :edit, layout: false }
      end
    end
  end

  private
    def response_set_params
      params.fetch(:response_set, {}).permit!
    end

    def set_response_set
      @response_set = ResponseSet.find(params[:id])
      raise Pundit::NotAuthorizedError if @response_set.nil?
    end
end
