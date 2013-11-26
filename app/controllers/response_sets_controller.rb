class ResponseSetsController < PublicController
  before_filter :require_account

  def new
    @participant = Participant.find(params[:participant_id])
    @response_set = @participant.response_sets.new
    @surveys = Survey.all.select{|s| s.active?}
    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  def create
    participant = Participant.find(params[:participant_id])
    @response_set= participant.response_sets.new(response_set_params)
    if @response_set.save
      participant.start_survey! if participant.survey?
      redirect_to(edit_response_set_path(@response_set))
    else
      flash[:notice] = @response_set.errors.full_messages.to_sentence
      redirect_to redirect_to enroll_participant_path(participant)
    end
  end

  def show
    @response_set= ResponseSet.find(params[:id])
    @survey = @response_set.survey
  end

  def edit
    @response_set= ResponseSet.find(params[:id]).reload
    @survey = @response_set.survey
    @section = @survey.sections.find_by_id(params[:section_id]).nil? ? @survey.sections.first : @survey.sections.find_by_id(params[:section_id])
  end

  def update
    @response_set= ResponseSet.find(params[:id])
    @response_set.update_attributes(response_set_params)
    participant = @response_set.participant
    if @response_set.save
      if params[:button].eql?("finish")
        @response_set.complete!
        @response_set.participant.process_enrollment! if participant.survey_started?
        redirect_to dashboard_path
      elsif params[:button].eql?("exit")
        redirect_to dashboard_path
      else
        redirect_to edit_response_set_path(@response_set, :section_id => params[:button])
      end
    else
      flash[:error] = @response_set.errors.full_messages.flatten.uniq.compact.to_sentence +  @response_set.responses.collect{|r| r.errors.full_messages}.flatten.uniq.compact.to_sentence
      redirect_to edit_response_set_path(@response_set)
    end
  end

  def response_set_params
    params.require(:response_set).permit(:all).tap do |whitelist|
      params[:response_set].each do |key,val|
        whitelist[key] = params[:response_set][key]
      end
    end
  end
end
