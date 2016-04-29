class Admin::StudiesController < Admin::AdminController
  before_action :set_study, only: [:show, :edit, :update, :destroy, :activate, :deactivate]

  def index
    authorize Study
    @studies = Study.all.order(state: :asc)
  end

  def new
    @study = Study.new
    authorize @study
  end

  def create
    @study = Study.new(study_params)
    authorize @study
    if @study.save
      flash['notice'] = 'Created'
    else
      flash['error'] = @study.errors.full_messages.to_sentence
    end
    redirect_to admin_studies_path
  end

  def show
    authorize @study
  end

  def edit
    authorize @study
  end

  def update
    authorize @study

    @study.update_attributes(study_params)
    if @study.save
      flash['notice'] = 'Updated'
    else
      flash['error'] = @study.errors.full_messages.to_sentence
    end
    redirect_to admin_study_path(@study)
  end

  def destroy
    authorize @study
    @study.destroy
    redirect_to admin_studies_path
  end

  def activate
    authorize @study
    @study.activate
    if @study.save
      flash['notice'] = 'Successfully activated'
    else
      flash['error'] = @study.errors.full_messages.to_sentence
    end
    redirect_to admin_studies_path
  end

  def deactivate
    authorize @study
    @study.deactivate
    if @study.save
      flash['notice'] = "Successfully activated"
    else
      flash['error'] = @study.errors.full_messages.to_sentence
    end
    redirect_to admin_studies_path
  end

  def search
    authorize Study
    @search = Study.search(params[:q])
    respond_to do |format|
      format.json {render json: @search.to_json(only: [:id], methods: [:search_display])}
    end
  end

  private
    def set_study
      @study = Study.find(params[:id])
    end

    def study_params
      params.require(:study).permit(:irb_number, :active_on, :inactive_on, :name, :short_title, :pi_name, :pi_email,
        :other_investigators, :contact_name, :contact_email, :short_title, :sites, :funding_source, :website, :start_date,
        :end_date, :min_age, :max_age, :accrual_goal, :number_of_visits, :protocol_goals, :inclusion_criteria, :exclusion_criteria)
    end
end

