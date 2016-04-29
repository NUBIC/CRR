class Admin::SectionsController < Admin::AdminController
  before_action :set_section, only: [:show, :edit, :update, :destroy]

  def new
    @survey = Survey.find(params[:survey_id])
    @section = @survey.sections.new
    authorize @section
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  def create
    @section = Section.new(section_params)
    authorize @section
    @survey = @section.survey
    if @section.save
      flash['notice'] = 'Updated'
    else
      flash['error'] = @section.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.js {render 'admin/surveys/show', layout: false}
    end
  end

  def show
    authorize @section
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  def edit
    authorize @section
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  def update
    authorize @section
    saved = @section.update_attributes(section_params)
    if saved
      flash['notice'] = 'Updated'
    else
      flash['error'] = @section.errors.full_messages.to_sentence
    end
    @section.reload
    respond_to do |format|
      format.html {redirect_to edit_survey_section_path(@survey_section)}
      format.js {render (saved ? :show : :edit), layout: false}
    end
  end

  def destroy
    authorize @section
    @survey = @section.survey
    @section.destroy
    @survey.reload
    respond_to do |format|
      format.js {render 'admin/surveys/show', layout: false}
    end
  end

  private
    def set_section
      @section = Section.find(params[:id])
    end

    def section_params
      params.require(:section).permit(:title, :display_order, :survey_id)
    end
end
