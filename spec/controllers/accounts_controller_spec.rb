require 'spec_helper'

describe AccountsController do
  let(:valid_attributes) { { email: "test@test.com", password: "1234", password_confirmation: "1234" } }
  let(:invalid_attributes) { { email: "test", password: "1234", password_confirmation: "1234" } }

  # describe "GET show" do
  #   it "assigns the requested account as @account" do
  #     account = Account.create! valid_attributes
  #     get :show, {:id => account.to_param}, valid_session
  #     exepect(assigns(:account)).to eq(account)
  #   end
  # end

  describe "GET new" do
    it "assigns a new account as @account" do
      get :new, {}, valid_attributes
      expect(assigns(:account)).to be_a_new(Account)
    end
    it "should use public layout" do
      get :new, {}, valid_attributes
      expect(response).to render_template("layouts/public")
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Account" do
        expect {
          post :create, {:account => valid_attributes}
        }.to change(Account, :count).by(1)
      end

      it "assigns a newly created account as @account" do
        post :create, {:account => valid_attributes}
        expect(assigns(:account)).to be_a(Account)
        expect(assigns(:account)).to be_persisted
      end

      it "redirects to the dashboard page" do
        post :create, {:account => valid_attributes}
        expect(response).to redirect_to dashboard_path
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved account as @account" do
        post :create, {:account => invalid_attributes}
        expect(assigns(:account)).to be_a_new(Account)
      end

      it "re-renders the 'new' template" do
        post :create, {:account => invalid_attributes}
        expect(response).to redirect_to(login_path(:anchor => "sign_up"))
      end
    end
  end

  describe "PUT update" do
    let(:account) { FactoryGirl.create(:account) }
    describe "with valid params" do
      it "updates the requested account" do 
        put :update, {:id => account.id, :account => valid_attributes}
      end

      it "assigns the requested account as @account" do
        put :update, {:id => account.id, :account => valid_attributes}
        expect(assigns(:account)).to eq(account)
      end

      it "redirects to the dashboard page" do
        put :update, {:id => account.id, :account => valid_attributes}
        expect(response).to redirect_to dashboard_path
      end
    end

    describe "with invalid params" do
      it "assigns the account as @account" do
        put :update, {:id => account.id, :account => invalid_attributes}
        expect(assigns(:account)).to eq(account)
      end

      it "re-renders the 'edit' template" do
        put :update, {:id => account.id, :account => invalid_attributes}
        expect(response).to render_template("edit")
      end
    end
  end
end