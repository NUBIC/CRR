class Admin::UsersController < Admin::AdminController
 def index
   @users = User.all
   authorize! :index, User
 end

 def new
   @user = User.new
   authorize! :new, @user
 end
 def create
   @user = User.new(user_params)
   authorize! :create, @user
   if @user.save
     flash[:notice] = "Created"
   else
     flash[:error] = @user.errors.full_messages.to_sentence
   end
   redirect_to admin_users_path
 end
 def edit
   @user = User.find(params[:id])
   authorize! :edit, @user
 end
 def update
   @user = User.find(params[:id])
   authorize! :update, @user
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
   authorize! :destroy, @user
   @user.destroy
   redirect_to admin_users_path
 end

 def dashboard
 end

 def user_params
   params.require(:user).permit(:netid,:researcher,:admin,:data_manager,:study_tokens)
 end
end

