class Admin::QuestionsController < Admin::AdminController
  before_action :set_question, only: [:show, :edit, :update, :destroy]

  def new
    @section  = Section.find(params[:section_id])
    @question = @section.questions.new
    authorize @question
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  def create
    @question =  Question.new(question_params)
    authorize @question
    @section = @question.section
    if @question.save
      flash['notice'] = 'Created'
    else
      flash['error'] = @question.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.js { render 'admin/sections/show', layout: false}
    end
  end

  def show
    authorize @question
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def edit
    authorize @question
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def update
    authorize @question
    saved = @question.update_attributes(question_params)
    if saved
      flash['notice'] = 'Updated'
    else
      flash['error'] = @question.errors.full_messages.to_sentence
    end
    @question.reload
    respond_to do |format|
      format.js { render :show, layout: false }
    end
  end

  def destroy
    authorize @question
    @section = @question.section
    @question.destroy
    flash['notice'] = 'Question Deleted'
    @section.reload
    respond_to do |format|
      format.js { render 'admin/sections/show', layout: false }
    end
  end

  def search
    authorize Question
    @questions = Question.search(params[:q])
    respond_to do |format|
      format.json { render json: @questions.to_json( only: [:id, :text], methods: [:search_display, :survey_title])}
    end
  end

  private
    def set_question
      @question = Question.find(params[:id])
    end

    def question_params
      params.require(:question).permit(:text,:response_type,:code,:help_text,:display_order,:is_mandatory,:survey_id,:section_id)
    end
end
