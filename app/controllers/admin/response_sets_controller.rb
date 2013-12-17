class Admin::ResponseSetsController < Admin::AdminController

  def index
    @participant = Participant.find(params[:participant_id])
    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  def new
    @participant = Participant.find(params[:participant_id])
    @response_set = @participant.response_sets.new
    authorize! :new, @response_set
    @surveys = Survey.all.select{|s| s.active?}
    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  def create
    @response_set= ResponseSet.new(response_set_params)
    authorize! :create, @response_set
    @participant = @response_set.participant
    saved = @response_set.save
    if saved
      @participant.start_survey! if @participant.survey?
    else
      flash[:notice] = @response_set.errors.full_messages.to_sentence
      @surveys = Survey.all.select{|s| s.active?}
    end
    respond_to do |format|
      format.js {render (saved ? (@response_set.public? ? :index : :edit) : :new), :layout => false}
    end
  end

  def show
    @response_set= ResponseSet.find(params[:id])
    authorize! :show, @response_set
    @survey = @response_set.survey
  end

  def edit
    @response_set= ResponseSet.find(params[:id]).reload
    authorize! :edit, @response_set
    @survey = @response_set.survey
    @section = @survey.sections.find_by_id(params[:section_id]).nil? ? @survey.sections.first : @survey.sections.find_by_id(params[:section_id])
  end

  def update
    @response_set= ResponseSet.find(params[:id])
    authorize! :update, @response_set
    @response_set.update_attributes(response_set_params)
    participant = @response_set.participant
    if @response_set.save
      if params[:button].eql?("finish")
        if @response_set.can_complete?
          @response_set.complete!
          @response_set.participant.enroll! if participant.survey_started?
          return redirect_to admin_participant_path(@response_set.participant)
        else
          flash[:error] = "Required field(s): missing information. Please review all sections of the survey."
          redirect_to edit_admin_response_set_path(@response_set)
        end
      elsif params[:button].eql?("exit")
        return redirect_to admin_participant_path(@response_set.participant)
      else
        redirect_to edit_admin_response_set_path(@response_set, :section_id => params[:button])
      end
    else
      flash[:error] = @response_set.errors.full_messages.flatten.uniq.compact.to_sentence +  @response_set.responses.collect{|r| r.errors.full_messages}.flatten.uniq.compact.to_sentence
      redirect_to edit_admin_response_set_path(@response_set)
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
