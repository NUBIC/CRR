class Admin::AnswersController < Admin::AdminController
  before_action :set_answer, only: [:show, :edit, :update, :destroy]

  def new
    @question = Question.find(params[:question_id])
    @answer   = @question.answers.new
    authorize @answer

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def create
    @answer = Answer.new(answer_params)
    authorize @answer

    if @answer.save
      flash['notice'] = 'Updated'
    else
      flash['error'] = @answer.errors.full_messages.to_sentence
    end

    @question = @answer.question.reload
    respond_to do |format|
      format.html { redirect_to edit_admin_question_path(@question) }
      format.js { render 'admin/questions/show', layout: false }
    end
  end

  def show
    authorize @answer
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def edit
    authorize @answer
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def update
    authorize @answer
    if @answer.update_attributes(answer_params)
      flash['notice'] = 'Updated'
    else
      flash['error'] = @answer.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.js { render :show, layout: false }
    end
  end

  def destroy
    authorize @answer
    @question = @answer.question
    @answer.destroy
    @question.reload
    respond_to do |format|
      format.js { render 'admin/questions/show', layout: false }
    end
  end

  private
    def set_answer
      @answer = Answer.find(params[:id])
    end

    def answer_params
      params.require(:answer).permit(:text,:code,:help_text,:display_order,:question_id)
    end
end
