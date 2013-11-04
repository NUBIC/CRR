class Admin::StudiesController < ApplicationController
  include Aker::Rails::SecuredController
 def index
   @studies = Study.all
 end

 def search

 end

 def new
   @study = Study.new
 end
 def create
   @study = Study.new(study_params)
   if @study.save
     flash[:notice] = "Created"
   else
     flash[:error] = @study.errors.full_messages.to_sentence
   end
   redirect_to admin_studies_path
 end
 def edit
   @study = Study.find(params[:id])
 end
 def update
   @study = Study.find(params[:id])
   @study.update_attributes(study_params)
   if @study.save
     flash[:notice] = "Updated"
   else
     flash[:error] = @study.errors.full_messages.to_sentence
   end
   redirect_to admin_studies_path
 end
 def destroy
   @study = Study.find(params[:id])
 end

 def study_params
   params.require(:study).permit(:irb_number,:active_on,:inactive_on,:name)
 end
end

