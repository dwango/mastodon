require 'rails_helper'

RSpec.describe Api::V1::FavouriteTagsController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { double acceptable?: true, resource_owner_id: user.id }
  let(:favourite_tag) { Fabricate(:favourite_tag, account: user.account) }

  before do
    favourite_tag
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    before do
      post :create, params: { name: 'my_favourite_tag' }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'creates the favourite_tag' do
      expect(user.account.favourite_tags.count).to eq 2
    end
  end

  describe 'DELETE #destroy' do
    before do
      delete :destroy, params: { id: favourite_tag.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'removes the favourite_tag' do
      expect(FavouriteTag.find_by(id: favourite_tag.id)).to be nil
    end
  end
end
