require 'csv'

class Admin::ResponseSetsController < Admin::AdminController
  before_action :set_response_set, only: [:show, :edit, :update, :destroy, :load_from_file]

  def index
    authorize ResponseSet
    @participant = Participant.find(params[:participant_id])
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def new
    @participant  = Participant.find(params[:participant_id])
    @response_set = @participant.response_sets.new
    authorize @response_set
    @surveys = Survey.all.select{|s| s.active?}
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  def create
    @response_set = ResponseSet.new(response_set_params)
    authorize @response_set

    @participant = @response_set.participant
    saved = @response_set.save
    unless saved
      flash['error'] = @response_set.errors.full_messages.to_sentence
      @surveys = Survey.all.select{|s| s.active?}
    end
    respond_to do |format|
      # format.js{ render (saved ? (@response_set.public? ? admin_participant_path(@response_set.participant, tab: "surveys") : :edit) : :new), layout: false}
      format.html{ saved ? @response_set.public? ? redirect_to(admin_participant_path(@response_set.participant, tab: 'surveys')) : redirect_to(edit_admin_response_set_path(@response_set.reload)) : render(action: :new)}
    end
  end

  def edit
    authorize @response_set
    @survey = @response_set.survey
    @section = @survey.sections.find_by_id(params[:section_id]).nil? ? @survey.sections.first : @survey.sections.find_by_id(params[:section_id])
  end

  def update
    authorize @response_set
    @survey = @response_set.survey
    @response_set.update_attributes(response_set_params)
    finish = params[:button].eql?('finish')

    unless @response_set.save && (!finish || finish && @response_set.reload.complete!)
      flash['error'] = @response_set.errors.full_messages.flatten.uniq.compact.to_sentence +  @response_set.responses.collect{|r| r.errors.full_messages}.flatten.uniq.compact.to_sentence
    end

    if finish && flash['error'].blank?
      respond_to do |format|
        format.html { redirect_to admin_participant_path(@response_set.participant, tab: 'surveys') }
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_admin_response_set_path(@response_set.reload) }
        format.js   { render :edit, layout: false }
      end
    end
  end

  def destroy
    authorize @response_set
    @participant = @response_set.participant
    @response_set.destroy
    redirect_to admin_participant_path(@participant, tab: 'surveys')
  end

  def load_from_file
    authorize @response_set
    sections        = @response_set.survey.sections.to_a
    uploaded_io     = params[:import_file]
    pin_header      = 'PIN'
    section_header  = 'Inst'
    errors          = []
    responses       = @response_set.responses
    if uploaded_io.blank?
      errors << 'File in not provided'
    else
      begin
        CSV.new(uploaded_io.read, { headers: true }).each do |row|
          unless row[pin_header].blank?
            if row[pin_header] != @response_set.participant.id.to_s
              errors << 'Participant PIN does not match'
            else
              section = sections.select{|s| s.title == row[section_header]}.first
              if section.blank?
                errors << "section '#{row[section_header]}' could not be found"
              else
                questions = section.questions
                row.headers.reject{|h| [pin_header, section_header].include?(h)}.each do |header|
                  question = questions.select{|q| q.text ==  header}.first
                  if question.blank?
                    errors << "question '#{header}' could not be found"
                  else
                    response = responses.select{|r| r.question_id == question.id}.first
                    response ||= @response_set.responses.build(question: question)
                    response.text = row[header]
                  end
                end
              end
            end
          end
        end
      rescue Exception => e
        errors << 'Error parsing the file' + e.inspect
      end
    end
    flash['error'] = errors.uniq.join('<br/>').html_safe if errors.any?
    render :edit
  end

  private
    def set_response_set
      @response_set = ResponseSet.find(params[:id])
    end

    def response_set_params
      params.fetch(:response_set, {}).permit!
    end
end
