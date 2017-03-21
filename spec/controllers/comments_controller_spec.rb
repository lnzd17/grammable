require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  describe "comments#create action" do
    it "should allow an authenticated user to create comments on grams" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user
      post :create, params: {gram_id: gram.id, comment: {message: 'awesome gram'}}
      expect(response).to redirect_to root_path
      expect(gram.comments.length).to eq 1
      expect(gram.comments.first.message).to eq "awesome gram"
    end

    it "should require a user to be logged in before commenting on a gram " do
      gram = FactoryGirl.create(:gram)
      post :create, params: {gram_id: gram.id, comment: {message: 'awesome gram'}}
      expect(response).to redirect_to new_user_session_path
    end

    it "should return http status code of not found if the gram doesn't exist to an authenticated user" do
      user = FactoryGirl.create(:user)
      sign_in user
      post :create, params: {gram_id: 'fake_id', comment: {message: 'awesome gram'}}
      expect(response).to have_http_status(:not_found)
    end
  end
end
