class Admin::SearchConditionsController < Admin::AdminController
  def index
    @search_condition_conditions = SearchCondition.data_requested + SearchCondition.data_released
  end

  def new
    @search_condition    = SearchCondition.new(search_condition_group_id: params[:search_condition_group_id])
    @available_questions = Question.unscoped.joins(section: :survey).where("response_type != 'none'").order('surveys.title, questions.display_order')
  end

  def create
    @search_condition = SearchCondition.new(search_condition_params)
    unless @search_condition.save
      flash[:error] = @search_condition.errors.full_messages.to_sentence
      render :new
    else
      render :edit
    end
  end

  def edit
    @search_condition = SearchCondition.find(params[:id])
  end

  def show
    @search_condition = SearchCondition.find(params[:id])
  end

  def update
    @search_condition = SearchCondition.find(params[:id])
    @search_condition.update_attributes(search_condition_params)
    if @search_condition.save
      flash[:notice] = "Updated"
    else
      flash[:error] = @search_condition.errors.full_messages.to_sentence
    end
    redirect_to admin_search_path(@search_condition.get_search)
  end

  def destroy
    @search_condition = SearchCondition.find(params[:id])
    @search = @search_condition.get_search
    @search_condition.destroy
    redirect_to admin_search_path(@search)
  end

  def search_condition_params
    params.require(:search_condition).permit( :search_condition_group_id, :operator, :question_id, :answer_id, :value, :calculated_date_number, :calculated_date_units)
  end
end

