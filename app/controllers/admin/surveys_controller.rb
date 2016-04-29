class Admin::SurveysController < Admin::AdminController
  before_action :set_survey, only: [:show, :edit, :update, :destroy, :activate, :deactivate, :preview]

  def index
   authorize Survey
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  def new
    @survey = Survey.new
    authorize @survey
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  def create
    @survey =  Survey.new(survey_params)
    authorize @survey
    if @survey.save
      flash['notice'] = 'Updated'
    else
      flash['error'] = @survey.errors.full_messages.to_sentence
      @study = @survey.study
    end
    respond_to do |format|
      format.html {redirect_to admin_surveys_path}
      format.js { render (@survey.save ? :show : :index), layout: false }
    end
  end

  def show
    authorize @survey
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  def edit
    authorize @survey
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  def update
    authorize @survey
    saved = @survey.update_attributes(survey_params)
    if saved
      flash['notice'] = 'Updated'
    else
      flash['error'] = @survey.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.html {render (saved ? :show : :edit)}
      format.js { render (saved ? :show : :edit), layout: false }
    end
  end

  def destroy
    authorize @survey
    @survey.destroy
    respond_to do |format|
      format.html {redirect_to admin_surveys_path}
      format.js {render :index, ayout: false}
    end
  end

  def activate
    authorize @survey
    @survey.state='active'
    if @survey.save
      flash['notice'] = 'Successfully activated'
    else
      flash['error'] = @survey.errors.full_messages.to_sentence
    end
    @survey.reload
    respond_to do |format|
      format.js {render :show, layout: false}
    end
  end

  def deactivate
    authorize @survey
    @survey.state='inactive'
    if @survey.save
      flash['notice'] = 'Successfully Deactivated'
    else
      flash['error'] = @survey.errors.full_messages.to_sentence
    end
    @survey.reload
    respond_to do |format|
      format.js {render :show, layout: false}
    end
  end

  def preview
    authorize @survey
    @response_set = @survey.response_sets.new
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  private
    def set_survey
      @survey = Survey.find(params[:id])
    end

    def survey_params
      params.require(:survey).permit(:title,:description,:multiple_section,:code)
    end
end
