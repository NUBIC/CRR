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
    unless saved
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
    @survey = @response_set.survey
    @response_set.update_attributes(response_set_params)
    unless @response_set.save and (!params[:button].eql?("finish") || @response_set.reload.complete!)
      flash[:error] = @response_set.errors.full_messages.flatten.uniq.compact.to_sentence +  @response_set.responses.collect{|r| r.errors.full_messages}.flatten.uniq.compact.to_sentence
    end
    respond_to do |format|
      format.html{ redirect_to (@response_set.errors.empty? and params[:button].eql?("finish")) ? admin_participant_path(@response_set.participant, tab: "surveys") : edit_admin_response_set_path(@response_set.reload)}
      format.js {render ((flash[:error].blank? and params[:button].eql?("finish")) ? admin_participant_path(@response_set.participant, tab: "surveys") : :edit),:layout=>false}
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
