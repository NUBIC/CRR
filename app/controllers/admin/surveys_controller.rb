class Admin::SurveysController < Admin::AdminController
  def index
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def new
    @survey = Survey.new
    authorize! :new, @survey
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def show
    @survey = Survey.find(params[:id])
    authorize! :new, @show
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def edit
    @survey = Survey.find(params[:id])
    authorize! :edit, @show
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def update
    @survey = Survey.find(params[:id])
    authorize! :update, @show
    saved = @survey.update_attributes(survey_params)
    if saved
      flash[:notice] = "Updated"
    else
      flash[:error] = @survey.errors.full_messages.to_sentence
    end
    @study.reload
    respond_to do |format|
      format.html {redirect_to edit_study_path(@study)}
      format.js {render (saved ? :index : :edit),:layout => false}
    end
  end

  def create
    @survey =  Survey.new(survey_params)
    authorize! :create, @show
    if @survey.save
      flash[:notice] = "Updated"
    else
      flash[:error] = @survey.errors.full_messages.to_sentence
      @study = @survey.study
    end
    respond_to do |format|
      format.html {redirect_to surveys_path}
      format.js {render (@survey.save ? :show : :index),:layout => false}
    end
  end

  def destroy
    @survey = Survey.find(params[:id])
    authorize! :destroy, @show
    @survey.destroy
    respond_to do |format|
      format.html {redirect_to admin_studies_path(@study)}
      format.js {render :index,:layout => false}
    end
  end
  def activate
    @survey = Survey.find(params[:id])
    authorize! :activate, @show
    @survey.state='active'
    if @survey.save
      flash[:notice]="Successfully activated"
    else
      flash[:error]=@survey.errors.full_messages.to_sentence
    end
    @survey.reload
    respond_to do |format|
      format.js {render :show,:layout => false}
    end
  end
  def deactivate
    @survey = Survey.find(params[:id])
    authorize! :activate, @show
    @survey.state='inactive'
    if @survey.save
      flash[:notice]="Successfully Deactivated"
    else
      flash[:error]=@survey.errors.full_messages.to_sentence
    end
    @survey.reload
    respond_to do |format|
      format.js {render :show,:layout => false}
    end
  end

  def preview
    @survey = Survey.find(params[:id])
    authorize! :preview, @show
    @response_set = @survey.response_sets.new
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
 def survey_params
   params.require(:survey).permit(:title,:description,:multiple_sections,:code)
 end
end
