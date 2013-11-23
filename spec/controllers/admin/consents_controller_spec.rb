require 'spec_helper'

describe Admin::ConsentsController do
  before(:each) do
    @consent = FactoryGirl.create(:consent)
    login_as("brian")
    controller.current_user.stub(:has_system_access?).and_return(true)
    controller.current_user.should == Aker.authority.find_user("brian")
  end

  describe "unauthorized access" do 

    ["data_manager?","researcher?"].each do |role|
      before(:each) do 
        controller.current_user.stub(:admin?).and_return(false)
        all_roles = ["data_manager?","researcher?"]
        all_roles.each{|r| r.eql?(role) ? controller.current_user.stub(r.to_sym).and_return(true) : controller.current_user.stub(r.to_sym).and_return(false)}
      end
  
      it "should deny access to an attempt by a #{role} to create a consent" do
        post :create, {:consent=>{:content=>"test"}}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end


      it "should deny access to an attempt to edit a consent by a #{role}" do
        post :edit, {:id=>@consent.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end


      it "should deny access to an attempt to update a consent by a #{role}" do
        post :update, {:id=>@consent.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end

      it "should deny access to an attempt to delete a consent by a #{role}" do
        post :destroy, {:id=>@consent.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end

      it "should deny access to an attempt to activate a consent by a #{role}" do
        put :activate, {:id=>@consent.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end
      it "should deny access to an attempt to deactivate a consent by a #{role}" do
        put :deactivate, {:id=>@consent.id}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end
    end
  end

  describe "authorized user" do 

    before(:each) do 
      controller.current_user.stub(:admin?).and_return(true)
    end
    describe "active consent" do 
      before(:each) do 
        @consent.state= "active"
        @consent.save
        @consent.reload.state.should == "active"
      end

      it "should allow access to dectivate a consent by an authorized user" do
        put :deactivate, {:id=>@consent.id,:format => :js}
        response.should redirect_to(admin_consents_path)
        @consent.reload.state.should == "inactive"
      end
      it "should deny access to edit  an active consent by an authorized user" do
        get :edit, {:id=>@consent.id,:format => :js}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end
      it "should deny access to update an inactive consent by an authorized user" do
        put :update, {:id=>@consent.id,:consent=>{:title=>'a second consent'},:format => :js}
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end
      it "should deny access to delete an inactive consent by an authorized user" do
        put :destroy, {:id=>@consent.id}
        Consent.all.size.should ==1
        response.should redirect_to(admin_default_path)
        flash[:notice].should == "Access Denied"
      end
    end
    describe "inactive consent" do 

      it "should allow access to an attempt to create a consent by an authorized user" do
        post :create, {:consent=>{:content=>'a second consent',:consent_type=>"adult"}}
        response.should redirect_to(admin_consents_path)
        Consent.all.size.should == 2
      end
      it "should allow access to edit  a consent by an authorized user" do
        get :edit, {:id=>@consent.id}
        response.should render_template("edit")
      end
      it "should allow access to update a consent by an authorized user" do
        put :update, {:id=>@consent.id,:consent=>{:content=>'a second consent',:consent_type=>"adult"}}
        response.should redirect_to(admin_consents_path)
        @consent.reload.content.should == "a second consent"
      end
      it "should allow access to activate a consent by an authorized user" do
        @consent.state.should == "inactive"
        put :activate, {:id=>@consent.id}
        response.should redirect_to(admin_consents_path)
        @consent.reload.state.should == "active"
      end
      it "should allow access to delete a consent by an authorized user" do
        put :destroy, {:id=>@consent.id}
        Consent.all.size.should ==0 
        response.should redirect_to(admin_consents_path)
      end

      describe "with signed consent signatures "do 
        before(:each) do 
          participant = FactoryGirl.create(:participant)
          consent_signature = FactoryGirl.create(:consent_signature,:participant=>participant,:consent=>@consent)
        end

        it "should deny access to delete a consent" do 
          put :destroy, {:id=>@consent.id}
          Consent.all.size.should ==1
          response.should redirect_to(admin_default_path)
          flash[:notice].should == "Access Denied"
        end

        it "should deny access to edit consent" do 
          get :edit, {:id=>@consent.id}
          response.should redirect_to(admin_default_path)
          flash[:notice].should == "Access Denied"
        end

        it "should deny access to update consent" do 
          put :update, {:id=>@consent.id,:consent=>{:title=>'a second consent'},:format => :js}
          response.should redirect_to(admin_default_path)
          flash[:notice].should == "Access Denied"
        end
      end
    end
    it "should allow access to view a consent by an authorized user" do
      get :show, {:id=>@consent.id}
      response.should render_template("show")
    end
    it "should allow access to an attempt to create a consent by an authorized user" do
      post :create, {:consent=>{:title=>'a second consent'}}
      Consent.all.size.should ==2
      response.should redirect_to(admin_consents_path)
    end
  end
end
