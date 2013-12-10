class Admin::StudiesController < Admin::AdminController
 def index
   @studies = Study.all
   authorize! :index, Study
 end

 def search
   @searchs = Study.search(params[:q])
   respond_to do |format|
     format.json {render :json => @searchs.to_json(:only=>[:id],:methods=>[:search_display])}
   end
 end

 def new
   @study = Study.new
   authorize! :new, @study
 end
 def create
   @study = Study.new(study_params)
   authorize! :create, @study
   if @study.save
     flash[:notice] = "Created"
   else
     flash[:error] = @study.errors.full_messages.to_sentence
   end
   redirect_to admin_studies_path
 end
 def edit
   @study = Study.find(params[:id])
   authorize! :edit, @study
 end
 def show
   @study = Study.find(params[:id])
   authorize! :show, @study
 end
 def update
   @study = Study.find(params[:id])
   authorize! :update, @study
   @study.update_attributes(study_params)
   if @study.save
     flash[:notice] = "Updated"
   else
     flash[:error] = @study.errors.full_messages.to_sentence
   end
   redirect_to admin_study_path(@study)
 end
  def activate
    @study = Study.find(params[:id])
    authorize! :activate, @study
    @study.state='active'
    if @study.save
      flash[:notice]="Successfully activated"
    else
      flash[:error]=@study.errors.full_messages.to_sentence
    end
    redirect_to admin_studies_path
  end
  def deactivate
    @study = Study.find(params[:id])
    authorize! :deactivate, @study
    @study.state='inactive'
    if @study.save
      flash[:notice]="Successfully activated"
    else
      flash[:error]=@study.errors.full_messages.to_sentence
    end
    redirect_to admin_studies_path
 end
 def destroy
   @study = Study.find(params[:id])
   authorize! :destroy, @study
   @study.destroy
   redirect_to admin_studies_path
 end

 def study_params
   params.require(:study).permit(:irb_number,:active_on,:inactive_on,:name,:short_title,:pi_name,:pi_email,:other_investigators,:contact_name,:contact_email,:short_title,:sites,:funding_source,:website,:start_date,:end_date,:min_age,:max_age,:accrual_goal,:number_of_visits,:protocol_goals,:inclusion_criteria,:exclusion_criteria)
 end
end

