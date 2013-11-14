class Admin::UsersController < ApplicationController
  include Aker::Rails::SecuredController
 def index
   @users = User.all
 end

 def new
   @user = User.new
 end
 def create
   @user = User.new(user_params)
   if @user.save
     flash[:notice] = "Created"
   else
     flash[:error] = @user.errors.full_messages.to_sentence
   end
   redirect_to users_path
 end
 def edit
   @user = User.find(params[:id])
 end
 def update
   @user = User.find(params[:id])
   @user.update_attributes(user_params)
   if @user.save
     flash[:notice] = "Updated"
   else
     flash[:error] = @user.errors.full_messages.to_sentence
   end
   redirect_to admin_users_path
 end
 def destroy
   @user = User.find(params[:id])
   @user.destroy
   redirect_to admin_users_path
 end

 def dashboard
 end

 def user_params
   params.require(:user).permit(:netid,:researcher,:admin,:data_manager,:study_tokens)
 end
end

