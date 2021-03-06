require 'rails_helper'

RSpec.describe GramsController, type: :controller do
  describe "grams#destroy action" do
    it "shouldn't allow users who didn't create a gram to destroy it" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user
      delete :destroy, params: {id: gram.id}
      expect(response).to have_http_status(:forbidden)
    end

    it "shouldn't let unauthenticated users destroy a gram" do
      gram = FactoryGirl.create(:gram)
      delete :destroy, params: {id: gram.id}
      expect(response).to redirect_to new_user_session_path
    end

    it "should allow an authenticated user to destroy a gram" do
      gram = FactoryGirl.create(:gram)
      sign_in gram.user
      delete :destroy, params: {id: gram.id}
      expect(response).to redirect_to root_path
      gram = Gram.find_by_id(gram.id)
      expect(gram).to eq nil
    end

    it "should return a 404 message if we cannot find the specified gram to an authenticated user" do
      user = FactoryGirl.create(:user)
      sign_in user
      delete :destroy, params: {id: 'fake_id'}
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#update action" do
    it "shouldn't let users who didn't create a gram update it" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user
      patch :update, params: { id: gram.id, gram: { message: 'hacked' } }
      expect(response).to have_http_status(:forbidden)
    end

    it "shouldn't let unauthenticated users create a gram" do
      gram = FactoryGirl.create(:gram)
      patch :update, params: {id: gram.id, gram:{message: "Hello"}}
      expect(response).to redirect_to new_user_session_path
    end

    it "should allow authenticated user to successfully update grams" do
      gram = FactoryGirl.create(:gram, message: "Initial Value")
      sign_in gram.user
      patch :update, params: {id: gram.id, gram: {message: "Changed"}}
      expect(response).to redirect_to root_path
      gram.reload
      expect(gram.message).to eq "Changed"
    end

    it "should return http 404 error if the specified gram cannot be found to an authenticated user" do
      user = FactoryGirl.create(:user)
      sign_in user
      patch :update, params: {id: 'fake_id', gram: {message: "Changed"}}
      expect(response).to have_http_status(:not_found)
    end

    it "should render the edit form with an http status of unprocessable_entity to an authenticated user" do
      gram = FactoryGirl.create(:gram, message: "Initial Value")
      sign_in gram.user
      patch :update, params: {id: gram.id, gram: {message: ''}}
      expect(response).to have_http_status(:unprocessable_entity)
      gram.reload
      expect(gram.message).to eq "Initial Value"
    end

  end

  describe "grams#edit action" do
    it "shouldn't let a user who did not create a gram edit it" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user
      get :edit, params: {id: gram.id}
      expect(response).to have_http_status(:forbidden)
    end

    it "shouldn't let unauthenticated users edit a gram" do
      gram = FactoryGirl.create(:gram)
      get :edit, params: {id: gram.id}
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the edit form if the gram is found to an authenticated user" do
      gram = FactoryGirl.create(:gram)
      sign_in gram.user
      get :edit, params: {id: gram.id}
      expect(response).to have_http_status(:success)
    end

    it "should return a 404 error if the gram is not found to an authenticated user" do
      user = FactoryGirl.create(:user)
      sign_in user
      get :edit, params: {id: 'fake_id'}
      expect(response).to have_http_status(:not_found)
    end

  end

  describe "grams#show action" do
    it "should successfully show the page if the gram is found" do
      gram = FactoryGirl.create(:gram)
      get :show, params: {id: gram.id}
      expect(response).to have_http_status(:success)
    end

    it "should return a 404 error if the gram is not found" do
      get :show, params: {id: 'TACOCAT'}
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#index action" do
    it "should successfully show the page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#new action" do
    it "should require a user to be logged in" do
      get :new
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the new form to an authenticated user" do
      user = FactoryGirl.create(:user)
      sign_in user
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#create action" do
    it "should require users to be logged in" do
      post :create, params: { gram: {message: "Hello"} }
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully save a new gram in our database to an authenticated user" do
      user = FactoryGirl.create(:user)
      sign_in user
      post :create, params: {
        gram: {
          message: 'Hello!',
          image: fixture_file_upload("/picture.jpeg", 'image/jpeg')
        }
      }
      expect(response).to redirect_to root_path
      gram = Gram.last
      expect(gram.message).to eq('Hello!')
      expect(gram.user).to eq(user)
    end

    it "should properly deal with the validation errors when an authenticated user attempts creation" do
      user = FactoryGirl.create(:user)
      sign_in user
      post :create, params: {gram: {message: ''}}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(Gram.count).to eq 0
    end
  end

end
