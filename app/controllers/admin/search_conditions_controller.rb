class Admin::SearchConditionsController < Admin::AdminController
  before_filter :set_search_condidion, only: [:edit, :show, :update, :destroy]
  before_filter :set_available_questions

  def index
    @search_condition_conditions = SearchCondition.data_requested + SearchCondition.data_released
  end

  def new
    @search_condition = SearchCondition.new(search_condition_group_id: params[:search_condition_group_id])
  end

  def create
    @search_condition = SearchCondition.new(search_condition_params)
    if @search_condition.save
      flash['notice'] = 'Updated'
      render :show
    else
      flash['error'] = @search_condition.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
  end

  def show
  end

  def update
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
    @search = @search_condition.get_search
    @search_condition.destroy
    redirect_to admin_search_path(@search)
  end

  def search_condition_values
    @question         = Question.find(params[:question_id])                 unless params[:question_id].blank?
    @search_condition = SearchCondition.find(params[:search_condition_id])  unless params[:search_condition_id].blank?
  end

  private
    def search_condition_params
      params.require(:search_condition).permit(
        :search_condition_group_id,
        :operator,
        :question_id,
        :answer_id,
        calculated_date_numbers: [],
        calculated_date_units: [],
        values: []
      )
    end

    def set_search_condidion
      @search_condition = SearchCondition.find(params[:id])
    end

    def set_available_questions
      @available_questions = Question.unscoped.joins(section: :survey).where.not(response_type: 'none').order('surveys.title, questions.display_order')
    end
end

