class UsersController < ApplicationController
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
   redirect_to users_path
 end
 def destroy
   @user = User.find(params[:id])
   @user.destroy
   redirect_to users_path
 end

 def user_params
   params.require(:user).permit(:netid,:researcher,:admin)
 end
end

