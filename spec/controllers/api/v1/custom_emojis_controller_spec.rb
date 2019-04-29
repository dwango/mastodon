# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::CustomEmojisController, type: :controller do
  render_views

  describe 'GET #index' do
    before do
      Fabricate(:custom_emoji)
      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { Fabricate(:user, admin: true) }
    before { sign_in user }
    let!(:custom_emoji) { Fabricate(:custom_emoji) }
    subject { delete :destroy, params: { id: custom_emoji.shortcode }  }
    it { expect { subject }.to change { CustomEmoji.count }.by(-1) }
    it do
      subject
      expect(response).to have_http_status(:success)
    end
  end
end
