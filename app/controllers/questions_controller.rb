class QuestionsController < ApplicationController
  include Aker::Rails::SecuredController


  def index
    @section= SurveySection.find(params[:survey_section_id])
    authorize! :show, @section
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def new
    @section = SurveySection.find(params[:survey_section_id])
    @question = @section.questions.new
    authorize! :edit, @question
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def show
    @question = Question.find(params[:id])
    authorize! :edit, @question
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def edit
    @question = Question.find(params[:id])
    authorize! :edit, @question
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def update
    @question = Question.find(params[:id])
    authorize! :update, @question
    saved = @question.update_attributes(params[:question])
    if saved
      flash[:notice] = "Updated"
    else
      flash[:error] = @question.errors.full_messages.to_sentence
    end
    @question.reload
    respond_to do |format|
      format.js {render :show,:layout => false}
    end
  end

  def create
    @question =  Question.new(params[:question])
    @section = @question.survey_section
    authorize! :update, @question
    if @question.save
      flash[:notice] = "Updated"
    else
      flash[:error] = @question.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.js {render "sections/show",:layout => false}
    end
  end

  def destroy
    @question = Question.find(params[:id])
    @section = @question.survey_section
    authorize! :destroy, @question
    @question.destroy
    flash[:notice] = "Question Deleted"
    @section.reload
    respond_to do |format|
      format.js {render "sections/show",:layout => false}
    end
  end
end
