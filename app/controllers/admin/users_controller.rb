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
     if @user.researcher?
      welcome_email = EmailNotification.active.find_by(email_type: EmailNotification::WELCOME_RESEARCHER)
      if welcome_email
        outbound_email(@user.email, welcome_email.content, 'Welcome to the communication research registry.')
      else
        flash[:error] = 'ATTENTION: Notification email message could not be sent (corresponding email could have been deactivated)'
      end
    end
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
  redirect_to admin_participants_path if can? :index, Participant
 end

 def user_params
   params.require(:user).permit(:netid,:researcher,:admin,:data_manager,:study_tokens)
 end
end

