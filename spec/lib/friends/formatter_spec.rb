# coding: utf-8
require 'rails_helper'

RSpec.describe Formatter do
  let(:account)  { Fabricate(:account, domain: nil, username: 'alice') }

  describe 'nicolink format' do
    let(:nicolink_status) { Fabricate(:status, text: text, account: account) }
    subject { Formatter.instance.format(nicolink_status) }

    context 'plain' do
      let(:text) { 'Hello world sm9' }
      it { is_expected.to include 'https://nico.ms/sm9' }
    end

    context 'temporal nicolink format' do
      let(:text) { 'Hello world sm9#1:30' }
      it { is_expected.to include 'https://nico.ms/sm9?from=90' }
    end

    context 'sm9 in url' do
      let(:text) { 'https://google.com/?q=sm9' }
      it { is_expected.not_to include 'https://nico.ms/sm9' }
    end

    context 'with domain' do
      let(:text) { 'このnicovideo.jp/watch/sm9はいいぞ' }
      it { is_expected.not_to include 'nicovideo.jp' }
    end
  end
end
