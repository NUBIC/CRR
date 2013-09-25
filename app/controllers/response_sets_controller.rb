class ResponseSetsController < ApplicationController
  def search
    @study = Study.find_by_irb_number(params[:study_id])
    authorize! :edit, @study
    @surveys = @study.surveys.active.where("title ilike ? ","%#{params[:q]}%")
    respond_to do |format|
      format.json {render :json => @surveys.to_json(:only=>[:id,:title])}
    end
  end

  def index
    @involvement = Involvement.find(params[:involvement_id])
    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  def new
    @study = Study.find_by_irb_number(params[:study_id])
    @involvement = Involvement.find(params[:involvement_id])
    @response_set = @involvement.response_sets.new
    @surveys = @study.surveys.select{|s| s.active?}
    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  def create
     @involvement = Involvement.find(params[:response_set][:involvement_id])
     @response_set= ResponseSet.create(params[:response_set])
     if @response_set.save
       redirect_to(edit_response_set_path(@response_set))
     else
       flash[:notice] = @response_set.errors.full_messages.to_sentence
       redirect_to @involvement
    end
  end

  def show
    @response_set= ResponseSet.find(params[:id])
    @survey = @response_set.survey
    @study = @survey.study
  end

  def edit
    @response_set= ResponseSet.find(params[:id])
    @survey = @response_set.survey
    @study = @survey.study
    @section = @survey.sections.find_by_id(params[:section_id]).nil? ? @survey.sections.first : @survey.sections.find_by_id(params[:section_id])
  end

  def update
    @response_set= ResponseSet.find(params[:id])
    @response_set.update_attributes(params[:response_set])
    if @response_set.save
      if params[:button].eql?("finish") 
        @response_set.complete! 
        flash[:notice] = @response_set.responses.collect{|r| r.errors.full_messages.to_sentence}.to_sentence  unless @response_set.save
      else
        flash[:notice] = "Form Successfully Saved"
      end
    else
      flash[:notice] = @response_set.responses.collect{|r| r.errors.full_messages.to_sentence}.to_sentence
    end
    return redirect_to involvement_path(@response_set.involvement,:tab=>"forms") if params[:button].eql?("exit")
    respond_to do |format|
      format.html do
        redirect_to edit_response_set_path(@response_set,:section_id=>params[:button])
      end
    end
  end

end
