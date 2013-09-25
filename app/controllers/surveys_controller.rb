class SurveysController < ApplicationController

  def index
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def new
    @survey = Survey.new
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def show
    @survey = Survey.find(params[:id])
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def edit
    @survey = Survey.find(params[:id])
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def update
    @survey = Survey.find(params[:id])
    saved = @survey.update_attributes(params[:survey])
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
    @survey =  Survey.new(params[:survey])
    if @survey.save
      flash[:notice] = "Updated"
    else
      flash[:error] = @survey.errors.full_messages.to_sentence
      @study = @survey.study
    end
    respond_to do |format|
      format.html {redirect_to edit_study_path(@study)}
      format.js {render (@survey.save ? :show : :index),:layout => false}
    end
  end

  def destroy
    @survey = Survey.find(params[:id])
    @survey.destroy
    respond_to do |format|
      format.html {redirect_to settings_study_path(@study)}
      format.js {render :index,:layout => false}
    end
  end
  def activate
    @survey = Survey.find(params[:id])
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
end
