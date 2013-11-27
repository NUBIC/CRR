class Admin::RelationshipsController < Admin::AdminController
 def index
   @participant = Participant.find(params[:participant_id])
   respond_to do |format|
     format.js {render :layout => false}
   end
 end

 def new
   @participant = Participant.find(params[:participant_id])
   @relationship = @participant.origin_relationships.new
   authorize! :new, @relationship
 end

 def edit
   @participant = Participant.find(params[:participant_id])
   @relationship = Relationship.find(params[:id])
   authorize! :edit, @relationship
 end

 def update
   @relationship = Relationship.find(params[:id])
   authorize! :update, @relationship
   @participant = @relationship.origin
   @relationship.update_attributes(relationship_params)
   if @relationship.save
     flash[:notice]="Updated relationship"
   else
     flash[:error]=@relationship.errors.full_messages.to_sentence
   end
    respond_to do |format|
      format.js {render :index,:layout => false}
    end
 end
 def create
   @relationship = Relationship.new(relationship_params)
   authorize! :create, @relationship
   if @relationship.save
     flash[:notice]="Added relationship"
   else
     flash[:error]=@relationship.errors.full_messages.to_sentence
   end
   @participant = @relationship.origin
    respond_to do |format|
      format.js {render :index,:layout => false}
    end
 end
 def destroy
   @relationship = Relationship.find(params[:id])
   authorize! :destroy, @relationship
   @relationship.destroy
   respond_to do |format|
    format.js {render :index,:layout => false}
   end
 end

 def relationship_params
   params.require(:relationship).permit(:origin_id,:destination_id,:notes,:category)
 end
end


