class AnswersController < ApplicationController
  include Aker::Rails::SecuredController



  def new
    @question = Question.find(params[:question_id])
    @answer = @question.answers.new
    authorize! :edit, @answer
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def show
    @answer = Answer.find(params[:id])
    authorize! :edit, @answer
    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  def edit
    @answer = Answer.find(params[:id])
    authorize! :edit, @answer
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def update
    @answer = Answer.find(params[:id])
    authorize! :update, @answer
    saved = @answer.update_attributes(params[:answer])
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
    @answer = Answer.new(params[:answer])
    @question = @answer.question
    authorize! :update, @answer
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
    authorize! :destroy, @answer
    @answer.destroy
    @question.reload
    respond_to do |format|
      format.js {render "questions/show",:layout => false}
    end
  end
end
