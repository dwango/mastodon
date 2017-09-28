# coding: utf-8
# frozen_string_literal: true
module Friends
  module ProcessHashtagsService
    extend ActiveSupport::Concern

    def call(status, tags = [])
      super(status, tags)
      return unless status.local?

      nicolinks = Extractor.extract_niconico_links_with_indices(status.text)
      tags = nicolinks.reduce([]) do |res, link|
        res << case link[:niconico_link].nico_id
               when NicoLink::VIDEO_RE
                 'ニコニコ動画タイムライン'
               when NicoLink::LIVE_RE
                 'ニコニコ生放送タイムライン'
               end
      end
      (tags.compact.uniq - status.tags.map(&:name)).each do |tag|
        status.tags << Tag.where(name: tag).first_or_initialize(name: tag)
      end
    end
  end
end
