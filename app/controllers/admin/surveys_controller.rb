class Admin::SurveysController < Admin::AdminController
  before_action :set_survey, only: [:show, :edit, :update, :destroy, :activate, :deactivate, :preview]

  def index
   authorize Survey
   @surveys = Survey.all
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def new
    @survey = Survey.new
    authorize @survey
  end

  def create
    @survey =  Survey.new(survey_params)
    authorize @survey
    if @survey.save
      redirect_to admin_survey_path(@survey), notice: 'Survey was successfully created.'
    else
      flash['error'] = @survey.errors.full_messages.to_sentence
      render :new
    end
  end

  def show
    authorize @survey
  end

  def edit
    authorize @survey
  end

  def update
    authorize @survey
    if @survey.update_attributes(survey_params)
      redirect_to admin_survey_path(@survey), notice: 'Survey was successfully updated.'
    else
      flash['error'] = @survey.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    authorize @survey
    @survey.destroy
    if @survey.destroyed?
      flash['notice'] = 'Survey was successfully destroyed.'
    else
      flash[:error] = 'Error destroying survey: ' + @survey.errors.full_messages.to_sentence
    end
    redirect_to admin_surveys_path
  end

  def activate
    authorize @survey
    @survey.activate
    if @survey.save
      flash['notice'] = 'Survey was successfully activated.'
    else
      flash['error'] = @survey.errors.full_messages.to_sentence
    end
    redirect_to admin_survey_path(@survey)
  end

  def deactivate
    authorize @survey
    @survey.deactivate
    if @survey.save
      flash['notice'] = 'Survey was successfully deactivated'
    else
      flash['error'] = @survey.errors.full_messages.to_sentence
    end
    redirect_to admin_survey_path(@survey)
  end

  def preview
    authorize @survey
    @response_set = @survey.response_sets.new
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  private
    def set_survey
      @survey = Survey.find(params[:id])
    end

    def survey_params
      params.require(:survey).permit(:title, :description, :multiple_section, :code, :tier_2)
    end
end
