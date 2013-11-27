require 'spec_helper'

describe Admin::RelationshipsController do
  before(:each) do
    @participant1 = FactoryGirl.create(:participant)
    @participant2 = FactoryGirl.create(:participant)
    @relationship = Relationship.create(:origin_id=>@participant1.id,:destination_id=>@participant2.id,:category=>"sibling")
    login_as("brian")
    controller.current_user.stub(:has_system_access?).and_return(true)
    controller.current_user.should == Aker.authority.find_user("brian")
  end

  describe "unauthorized access" do 

    ["researcher?"].each do |role|
      before(:each) do 
        controller.current_user.stub(:admin?).and_return(false)
        all_roles = ["data_manager?","researcher?"]
        all_roles.each{|r| r.eql?(role) ? controller.current_user.stub(r.to_sym).and_return(true) : controller.current_user.stub(r.to_sym).and_return(false)}
      end
  
      it "should deny access to an attempt by a #{role} to create a relationship" do
        post :create, {:relationship=>{:origin_id=>@participant1.id,:destination_id=>@participant2.id,:category=>"sibling"}}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end


      it "should deny access to an attempt to edit a relationship by a #{role}" do
        post :edit, {:id=>@relationship.id,:participant_id=>@participant1.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end


      it "should deny access to an attempt to update a relationship by a #{role}" do
        post :update, {:id=>@relationship.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end

      it "should deny access to an attempt to delete a relationship by a #{role}" do
        post :destroy, {:id=>@relationship.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end

    end
  end

  describe "authorized user" do 

    ["data_manager?","admin?"].each do |role|
      before(:each) do 
        controller.current_user.stub(:researcher?).and_return(true)
        all_roles = ["data_manager?","admin?"]
        all_roles.each{|r| r.eql?(role) ? controller.current_user.stub(r.to_sym).and_return(true) : controller.current_user.stub(r.to_sym).and_return(false)}
      end

      it "should allow access to an attempt to create a relationship by an #{role}" do
        participant3 = FactoryGirl.create(:participant)
        post :create, {:relationship=>{:category=>'sibling',:origin_id=>participant3.id,:destination_id=>@participant2.id},:format => :js}
        response.should render_template("index")
        Relationship.all.size.should == 2
      end
      it "should allow access to edit  a relationship by an #{role}" do
        get :edit, {:id=>@relationship.id,:participant_id=>@participant1.id}
        response.should render_template("edit")
      end
      it "should allow access to update a relationship by an #{role}" do
        put :update, {:id=>@relationship.id,:relationship=>{:category=>'parent'},:format => :js}
        response.should render_template("index")
        @relationship.reload.category.should == "parent"
      end
      it "should allow access to delete a relationship by an #{role}" do
        put :destroy, {:id=>@relationship.id,:format => :js}
        Relationship.all.size.should ==0 
        response.should render_template("index")
      end
    end
  end
end
