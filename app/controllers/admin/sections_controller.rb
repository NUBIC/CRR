class Admin::SectionsController < Admin::AdminController

  def new
    @survey = Survey.find(params[:survey_id])
    @section =@survey.sections.new
    authorize! :new, @section
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def show
    @section = Section.find(params[:id])
    authorize! :show, @section
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def edit
    @section = Section.find(params[:id])
    authorize! :edit, @section
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def update
    @section = Section.find(params[:id])
    authorize! :update, @section
    saved = @section.update_attributes(section_params)
    if saved
      flash[:notice] = "Updated"
    else
      flash[:error] = @survey.errors.full_messages.to_sentence
    end
    @section.reload
    respond_to do |format|
      format.html {redirect_to edit_survey_section_path(@survey_section)}
      format.js {render (saved ? :index : :edit),:layout => false}
    end
  end

  def create
    @section = Section.new(section_params)
    authorize! :create, @section
    @survey = @section.survey
    if @section.save
      flash[:notice] = "Updated"
    else
      flash[:error] = @section.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.js {render "admin/surveys/show",:layout => false}
    end
  end

  def destroy
    @section = Section.find(params[:id])
    authorize! :destroy, @section
    @survey = @section.survey
    @section.destroy
    @survey.reload
    respond_to do |format|
      format.js {render "admin/surveys/show",:layout => false}
    end
  end
 def section_params
   params.require(:section).permit(:title,:display_order,:survey_id)
 end
end
