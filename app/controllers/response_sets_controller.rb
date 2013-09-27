class ResponseSetsController < ApplicationController

  def index
    @participant = Participant.find(params[:participant_id])
    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  def new
    @participant = Participant.find(params[:participant_id])
    @response_set = @participant.response_sets.new
    @surveys = Survey.all.select{|s| s.active?}
    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  def create
     @participant = Participant.find(params[:response_set][:participant_id])
     @response_set= @participant.response_sets.new(response_set_params)
     if @response_set.save
       redirect_to(edit_response_set_path(@response_set))
     else
       flash[:notice] = @response_set.errors.full_messages.to_sentence
       redirect_to @participant
    end
  end

  def show
    @response_set= ResponseSet.find(params[:id])
    @survey = @response_set.survey
  end

  def edit
    @response_set= ResponseSet.find(params[:id]).reload
    Rails.logger.info @response_set.methods.sort
    @survey = @response_set.survey
    @section = @survey.sections.find_by_id(params[:section_id]).nil? ? @survey.sections.first : @survey.sections.find_by_id(params[:section_id])
  end

  def update
    @response_set= ResponseSet.find(params[:id])
    @response_set.update_attributes(params.require(:response_set).permit(@response_set.methods.collect{|att| att.to_sym}))
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
    return redirect_to participant_path(@response_set.participant,:tab=>"forms") if params[:button].eql?("exit")
    respond_to do |format|
      format.html do
        redirect_to edit_response_set_path(@response_set,:section_id=>params[:button])
      end
    end
  end

 def response_set_params
   params.require(:response_set).permit(:participant_id,:effective_date,:survey_id)
 end
end
