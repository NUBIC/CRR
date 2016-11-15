class Admin::SearchConditionsController < Admin::AdminController
  before_action :set_search_condidion, only: [:edit, :show, :update, :destroy]
  before_action :set_available_questions

  # def index
  #   authorize SearchCondition
  #   @search_condition_conditions = SearchCondition.data_requested + SearchCondition.data_released
  # end

  def new
    @search_condition = SearchCondition.new(search_condition_group_id: params[:search_condition_group_id])
    authorize @search_condition
  end

  def create
    @search_condition = SearchCondition.new(search_condition_params)
    authorize @search_condition

    if @search_condition.save
      flash['notice'] = 'Updated'
      render :show
    else
      flash['error'] = @search_condition.errors.full_messages.to_sentence
      render :new
    end
  end

  def show
    authorize @search_condition
  end

  def edit
    authorize @search_condition
  end

  def update
    authorize @search_condition
    params[:search_condition][:values] ||= []
    @search_condition.update_attributes(search_condition_params)
    if @search_condition.save
      flash['notice'] = 'Updated'
      render :show
    else
      flash['error'] = @search_condition.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    authorize @search_condition
    @search = @search_condition.get_search
    @search_condition.destroy
    redirect_to admin_search_path(@search)
  end

  def values
    authorize SearchCondition
    @search_condition   = SearchCondition.find(params[:id]) if params[:id]
    @question           = Question.find(params[:question_id]) unless params[:question_id].blank?
  end

  private
    def search_condition_params
      params.require(:search_condition).permit(
        :search_condition_group_id,
        :operator,
        :question_id,
        calculated_date_numbers: [],
        calculated_date_units: [],
        values: []
      )
    end

    def set_search_condidion
      @search_condition = SearchCondition.find(params[:id])
    end

    def set_available_questions
      available_questions = Question.unscoped.joins(section: :survey).where.not(response_type: 'none')
      unless current_user.admin?
        available_questions = available_questions.where( surveys: { tier_2: false })
      end
      @available_questions = available_questions.order('surveys.title, questions.display_order')
    end
end
