class Admin::QuestionsController < Admin::AdminController
  def index
    @section= Section.find(params[:section_id])
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
  def search
    @questions = Question.search(params[:q])
    respond_to do |format|
      format.json {render :json => @questions.to_json(:only=>[:id],:methods=>[:search_display])}
    end
  end

  def new
    @section = Section.find(params[:section_id])
    @question = @section.questions.new
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def show
    @question = Question.find(params[:id])
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def edit
    @question = Question.find(params[:id])
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def update
    @question = Question.find(params[:id])
    saved = @question.update_attributes(question_params)
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
    @question =  Question.new(question_params)
    @section = @question.section
    if @question.save
      flash[:notice] = "Updated"
    else
      flash[:error] = @question.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.js {render "admin/sections/show",:layout => false}
    end
  end

  def destroy
    @question = Question.find(params[:id])
    @section = @question.section
    @question.destroy
    flash[:notice] = "Question Deleted"
    @section.reload
    respond_to do |format|
      format.js {render "admin/sections/show",:layout => false}
    end
  end
 def question_params
   params.require(:question).permit(:text,:response_type,:code,:help_text,:display_order,:is_mandatory,:survey_id,:section_id)
 end
end
