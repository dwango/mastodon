# frozen_string_literal: true

module Friends
  module ProfileEmojiExtension
    extend ActiveSupport::Concern

    include RoutingHelper

    REDIS_TTL = 60.freeze
    PROFILE_EMOJI_RE = /:@(\w+):/.freeze
    IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif'].freeze

    def get_profile_emojis(text, redis_key=nil)
      profile_emojis_json = redis.get(redis_key)
      if profile_emojis_json.nil?
          return scan_profile_emojis_from_text text, redis_key
      else
        profile_emojis = JSON.load profile_emojis_json
        profile_emojis.map!(&:symbolize_keys)

        if is_updated_within_ttl? profile_emojis
          return scan_profile_emojis_from_text text, redis_key
        end
        return profile_emojis
      end
    end

    private

    def is_updated_within_ttl?(profile_emojis)
      profile_emojis.each do |profile_emoji|
        key = Friends::AvatarUpdateObserver::REDIS_FORMAT % profile_emoji[:shortcode]
        avatar_updated_at = redis.get(key)
        next if avatar_updated_at.nil?
        return true if avatar_updated_at.to_i - profile_emoji[:updated_at].to_i > 0
      end
      return false
    end

    def scan_profile_emojis_from_text(text, redis_key)
      scaned_usernames = []
      profile_emojis = text.scan(PROFILE_EMOJI_RE).map { |username|
        next if scaned_usernames.include? username
        a = Account.find_by(username: username)
        next if a.nil?
        scaned_usernames << username
        {
          # 'shortcode' and 'url' are matched to CustomEmoji.
          shortcode: a.username,
          url: full_asset_url(a.profile_emoji_static_url),
          account_id: a.id,
          account_url: short_account_url(a),
          updated_at: Time.now.utc.to_i,
        }
      }.compact
      return set_redis(profile_emojis, redis_key).nil? ? [] : profile_emojis
    end

    def set_redis(profile_emojis, redis_key)
      return if profile_emojis.empty?
      redis.setex(redis_key, REDIS_TTL, JSON.generate(profile_emojis))
    end

    def redis
      Redis.current
    end
  end
end
