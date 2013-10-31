class Admin::SectionsController < ApplicationController
  include Aker::Rails::SecuredController

  def new
    @survey = Survey.find(params[:survey_id])
    @section =@survey.sections.new
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def show
    @section = Section.find(params[:id])
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def edit
    @section = Section.find(params[:id])
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def update
    @section = Section.find(params[:id])
    saved = @survey.update_attributes(section_params)
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
    @survey = @section.survey
    if @section.save
      flash[:notice] = "Updated"
    else
      Rails.logger.info @section.errors.full_messages.to_sentence
      flash[:error] = @section.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.js {render "surveys/show",:layout => false}
    end
  end

  def destroy
    @section = Section.find(params[:id])
    @survey = @section.survey
    @section.destroy
    @survey.reload
    respond_to do |format|
      format.js {render "surveys/show",:layout => false}
    end
  end
 def section_params
   params.require(:section).permit(:title,:display_order,:survey_id)
 end
end
