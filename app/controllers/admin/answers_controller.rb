class Admin::AnswersController < ApplicationController
  include Aker::Rails::SecuredController



  def new
    @question = Question.find(params[:question_id])
    @answer = @question.answers.new
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def show
    @answer = Answer.find(params[:id])
    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  def edit
    @answer = Answer.find(params[:id])
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def update
    @answer = Answer.find(params[:id])
    saved = @answer.update_attributes(answer_params)
    if saved
      flash[:notice] = "Updated"
    else
      flash[:error] = @answer.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.js {render :show,:layout => false}
    end
  end

  def create
    @answer = Answer.new(answer_params)
    @question = @answer.question
    if @answer.save
      flash[:notice] = "Updated"
    else
      flash[:error] = @answer.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.html {redirect_to edit_question_path(@question)}
      format.js {render "questions/show",:layout => false}
    end
  end

  def destroy
    @answer = Answer.find(params[:id])
    @question = @answer.question
    @answer.destroy
    @question.reload
    respond_to do |format|
      format.js {render "questions/show",:layout => false}
    end
  end
 def answer_params
   params.require(:answer).permit(:text,:reference,:help_text,:display_order,:question_id,:weight)
 end
end
