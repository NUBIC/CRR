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
 end

 def edit
   @participant = Participant.find(params[:participant_id])
   @relationship = Relationship.find(params[:id])
 end

 def update
   @relationship = Relationship.find(params[:id])
   @participant = @relationship.participant
   @relationship.update_attributes(relationship_params)
   if @relationship.save
     flash[:notice]="Updated relationship"
   else
     flash[:notice]=@relationship.errors.full_messages.to_sentence
   end
    respond_to do |format|
      format.js {render :index,:layout => false}
    end
 end
 def create
   @relationship = Relationship.new(relationship_params)
   if @relationship.save
     flash[:notice]="Added relationship"
   else
     flash[:notice]=@relationship.errors.full_messages.to_sentence
   end
   @participant = @relationship.origin
    respond_to do |format|
      format.js {render :index,:layout => false}
    end
 end
 def destroy
   @relationship = Relationship.find(params[:id])
   @relationship.destroy
 end

 def relationship_params
   params.require(:relationship).permit(:origin_id,:destination_id,:notes,:category)
 end
end


