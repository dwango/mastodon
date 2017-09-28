# coding: utf-8
require 'rails_helper'

describe Friends::ProcessHashtagsService do
  let(:account) { Fabricate(:account, username: 'alice') }
  let(:status)  { Fabricate(:status, account: account, text: text) }
  let(:service) { ProcessHashtagsService.new }

  subject { service.call(status) }

  {video: '動画', live: '生放送'}.each do |type, text|
    shared_examples_for "#{type}_timeline".to_sym do
      it do
        subject
        expect(status.tags.map(&:name)).to include "ニコニコ#{text}タイムライン"
      end
    end
  end

  describe 'single' do
    let(:text) { 'sm9' }
    it_behaves_like :video_timeline
  end

  describe 'double' do
    let(:text) { 'sm9 sm9' }
    it_behaves_like :video_timeline
  end

  describe 'in tag' do
    let(:text) { '#sm9' }
    it_behaves_like :video_timeline
  end

  describe 'in url' do
    let(:text) { 'http://www.nicovideo.jp/watch/sm9' }
    it_behaves_like :video_timeline
  end

  describe 'multi' do
    let(:text) { 'sm9 lv1' }
    it_behaves_like :video_timeline
    it_behaves_like :live_timeline
  end

  describe 'with string' do
    let(:text) { 'sm9 #ニコニコ動画タイムライン' }
    it_behaves_like :video_timeline
    it do
      expect { subject }.to change { Tag.count }.by(1)
    end
  end

  describe 'not listed' do
    let(:text) { 'bk1' }
    it do
      expect { subject }.not_to change { Tag.count }
    end
  end

  describe 'remote status' do
    let(:account) { Fabricate(:account, domain: 'test.com') }
    let(:status) { Fabricate(:status, account: account, uri: 'a', text: text) }
    let(:text) { 'sm9' }

    it do
      expect { subject }.not_to change { Tag.count }
    end
  end
end
