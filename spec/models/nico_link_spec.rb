# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NicoLink, type: :model do
  describe 'NICOLINK_RE' do
    subject { NicoLink::NICOLINK_RE }

    context 'with time' do
      it 'matches nicolinks' do
        expect(subject.match('im9#11:10')).to_not be_nil
        expect(subject.match('im0009#11:10')).to_not be_nil

        expect(subject.match('lv9#11:10')).to_not be_nil
        expect(subject.match('lv0009#11:10')).to_not be_nil

        expect(subject.match('sm9#11:10')).to_not be_nil
        expect(subject.match('sm0009#11:10')).to_not be_nil
      end

      it 'matches nicolinks within Japanese text' do
        expect(subject.match('このim9#11:10が好き')).to_not be_nil
        expect(subject.match('つim90923#11:10は観たこと無いな')).to_not be_nil
        expect(subject.match('あim9#11:10９')).to_not be_nil

        expect(subject.match('このlv9#11:10が好き')).to_not be_nil
        expect(subject.match('つlv90923#11:10は観たこと無いな')).to_not be_nil
        expect(subject.match('あlv9#11:10９')).to_not be_nil

        expect(subject.match('このsm9#11:10が好き')).to_not be_nil
        expect(subject.match('つsm90923#11:10は観たこと無いな')).to_not be_nil
        expect(subject.match('あsm9#11:10９')).to_not be_nil
      end
    end

    context 'without time' do
      it 'matches nicolinks' do
        expect(subject.match('im9')).to_not be_nil
        expect(subject.match('im0009')).to_not be_nil

        expect(subject.match('lv9')).to_not be_nil
        expect(subject.match('lv0009')).to_not be_nil

        expect(subject.match('sm9')).to_not be_nil
        expect(subject.match('sm0009')).to_not be_nil

        expect(subject.match('nm9')).to_not be_nil
        expect(subject.match('nm0009')).to_not be_nil
      end

      it 'matches nicolinks within Japanese text' do
        expect(subject.match('このim9が好き')).to_not be_nil
        expect(subject.match('つim90923は観たこと無いな')).to_not be_nil
        expect(subject.match('あim9９')).to_not be_nil

        expect(subject.match('このlv9が好き')).to_not be_nil
        expect(subject.match('つlv90923は観たこと無いな')).to_not be_nil
        expect(subject.match('あlv9９')).to_not be_nil

        expect(subject.match('このsm9が好き')).to_not be_nil
        expect(subject.match('つsm90923は観たこと無いな')).to_not be_nil
        expect(subject.match('あsm9９')).to_not be_nil

        expect(subject.match('このnm9が好き')).to_not be_nil
        expect(subject.match('つnm90923は観たこと無いな')).to_not be_nil
        expect(subject.match('あnm9９')).to_not be_nil
      end
    end

    it 'does not match URLs' do
      expect(subject.match('https://example.com/sm9')).to be_nil
      expect(subject.match('https://example.com/Aha_(hello)sm9')).to be_nil
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
        subject.each do |key, _|
          expect(NicoLink.new('im0139401923849', key).to_href).to eq 'https://nico.ms/im0139401923849'
        end
      end

      it 'adds from param for temporal ids' do
        subject.each do |key, val|
          expect(NicoLink.new('lv84120982743', key).to_href).to eq "https://nico.ms/lv84120982743?from=#{val}"
          expect(NicoLink.new('sm9', key).to_href).to eq "https://nico.ms/sm9?from=#{val}"
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
        subject.each do |subj|
          expect(NicoLink.new('im0', subj).to_href).to eq 'https://nico.ms/im0'
        end
      end

      it 'does not add from param for temporal ids' do
        subject.each do |subj|
          expect(NicoLink.new('sm9', subj).to_href).to eq 'https://nico.ms/sm9'
        end
      end
    end

    context 'without time' do
      let(:im) { NicoLink.new('im0139401923849') }
      let(:lv) { NicoLink.new('lv84120982743') }
      let(:sm) { NicoLink.new('sm9') }

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
        a = []

        a << 'sm9'
        a << ' sm9'
        a << '　sm9'
        a << 'あsm9'
        a << 'sm9９'
        a << 'あsm9９'

        a << 'lv9'
        a << ' lv9'
        a << '　lv9'
        a << 'あlv9'
        a << 'lv9９'
        a << 'あlv9９'

        a << 'im9'
        a << ' im9'
        a << '　im9'
        a << 'あim9'
        a << 'im9９'
        a << 'あim9９'

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
