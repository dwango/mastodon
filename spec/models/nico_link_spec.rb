# coding: utf-8
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NicoLink, type: :model do

  describe 'NICO_DOMAIN_RE' do
    let(:regex) { /\A#{NicoLink::NICO_DOMAIN_RE}\z/ }

    %w(nicovideo.jp/
       nicovideo.jp/watch/
       www.nicovideo.jp/
       www.nicovideo.jp/watch/
       nico.ms/).each do |text|
      context text do
        it { expect(text).to match regex }
      end
    end

    %w(example.com/
       nico.ms/watch/
       example.nico.ms/
       nicovideo.example.com/).each do |text|
      context text do
        it { expect(text).not_to match regex }
      end
    end
  end

  describe 'NICOLINK_RE' do
    let(:regex) { NicoLink::NICOLINK_RE }
    let(:text) { self.class.metadata[:description] }
    subject { text }

    describe 'im9#11:10' do
      it { is_expected.to match regex }
    end
    describe 'im0009#11:10' do
      it { is_expected.to match regex }
    end

    context 'with time' do
      it 'matches nicolinks' do
        expect('lv9#11:10').to match regex
        expect('lv0009#11:10').to match regex

        expect('sm9#11:10').to match regex
        expect('sm0009#11:10').to match regex
      end

      it 'matches nicolinks within Japanese text' do
        %w(このim9#11:10が好き つim90923#11:10は観たこと無いな あim9#11:10９ このlv9#11:10が好き つlv90923#11:10は観たこと無いな あlv9#11:10９ このsm9#11:10が好き つsm90923#11:10は観たこと無いな あsm9#11:10９).each do |text|
          expect(text).to match regex
        end
      end
    end

    context 'without time' do
      %w(im9 im0009 lv9 lv0009 sm9 sm0009).each do |text|
        describe text do
          it { is_expected.to match regex }
        end
      end

      it 'matches nicolinks within Japanese text' do
        expect('このim9が好き').to match regex
        expect('つim90923は観たこと無いな').to match regex
        expect('あim9９').to match regex

        expect('このlv9が好き').to match regex
        expect('つlv90923は観たこと無いな').to match regex
        expect('あlv9９').to match regex

        expect('このsm9が好き').to match regex
        expect('つsm90923は観たこと無いな').to match regex
        expect('あsm9９').to match regex
      end
      describe 'mylist/1' do
        it { is_expected.to match regex }
      end
      describe 'nicovideo.jp/mylist/1' do
        it { is_expected.to match regex }
      end
    end

    describe 'enabled prefixs' do
      context 'このsm9' do
        it { is_expected.to match regex }
      end
      context '#sm9' do
        it { is_expected.to match regex }
      end
      context ' nicovideo.jp/watch/sm9?hello=world' do
        it { is_expected.to match regex }
      end
      context 'nico.ms/sm9' do
        it { is_expected.to match regex }
      end

      context 'https://example.com/sm9' do
        it { is_expected.not_to match regex }
      end
      context 'https://example.com/Aha_(hello)sm9' do
        it { is_expected.not_to match regex }
      end
      context 'https://example.com/hellosm9' do
        it { is_expected.not_to match regex }
      end
      context 'https://sm9.example.com/hellosm9' do
        it { is_expected.not_to match regex }
      end
    end

    describe 'url matching' do
      subject { regex.match(text)[:nico_domain] }
      describe 'このsm9' do
        it { is_expected.to eq nil }
      end
      describe 'このnico.ms/sm9' do
        it { is_expected.to eq 'nico.ms/' }
      end
      describe 'このhttps://nico.ms/sm9' do
        it { is_expected.to eq 'https://nico.ms/' }
      end
      describe 'このnico.ms/mylist/1' do
        it { is_expected.to eq 'nico.ms/' }
      end
    end
  end

  describe '#to_href' do
    context 'with valid time' do
      subject do
        {
          '0:01': 1,
          '0:02': 2,
          '0:10': 10,
          '00:01': 1,
          '00:02': 2,
          '00:10': 10,
          '2:59': 179,
          '02:59': 179,
          '99:59': 5999,
        }
      end

      it 'does not add from param for non-temporal ids' do
        subject.each do |time, _|
          expect(NicoLink.new(nico_id: 'im0139401923849', time: time).to_href).to eq 'https://nico.ms/im0139401923849'
        end
      end

      it 'adds from param for temporal ids' do
        subject.each do |time, val|
          expect(NicoLink.new(nico_id: 'lv84120982743', time: time).to_href).to eq "https://nico.ms/lv84120982743?from=#{val}"
          expect(NicoLink.new(nico_id: 'sm9', time: time).to_href).to eq "https://nico.ms/sm9?from=#{val}"
        end
      end
    end

    context 'with invalid time' do
      subject do
        %w[
          0:1
          00:00
          999
          9:60
          000099:59
          99:599
          999:59
        ]
      end

      it 'does not add from param for non-temporal ids' do
        subject.each do |time|
          expect(NicoLink.new(nico_id: 'im0', time: time).to_href).to eq 'https://nico.ms/im0'
        end
      end

      it 'does not add from param for temporal ids' do
        subject.each do |time|
          expect(NicoLink.new(nico_id: 'sm9', time: time).to_href).to eq 'https://nico.ms/sm9'
        end
      end
    end

    context 'without time' do
      let(:im) { NicoLink.new(nico_id: 'im0139401923849') }
      let(:lv) { NicoLink.new(nico_id: 'lv84120982743') }
      let(:sm) { NicoLink.new(nico_id: 'sm9') }

      it 'returns a proper href' do
        expect(im.to_href).to eq 'https://nico.ms/im0139401923849'
        expect(lv.to_href).to eq 'https://nico.ms/lv84120982743'
        expect(sm.to_href).to eq 'https://nico.ms/sm9'
      end
    end
  end

  describe '.parse' do
    context 'without time' do
      subject do
        a = ['sm9', ' sm9', '　sm9', 'あsm9', 'sm9９', 'あsm9９',
             'lv9', ' lv9', '　lv9', 'あlv9', 'lv9９', 'あlv9９',
             'im9', ' im9', '　im9', 'あim9', 'im9９', 'あim9９']
        a.map { |s| NicoLink.parse s }
      end

      it 'returns proper NicoLink' do
        subject.each do |subj|
          expect(subj.is_a?(NicoLink)).to be_truthy
        end
      end
    end
  end
end
