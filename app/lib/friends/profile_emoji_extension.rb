# frozen_string_literal: true

module Friends
  module ProfileEmojiExtension
    extend ActiveSupport::Concern

    include RoutingHelper

    REDIS_TTL = 60.freeze
    PROFILE_EMOJI_RE = /:@(\w+):/
    IMAGE_MIME_TYPES = ['image/jpeg', 'image/png', 'image/gif'].freeze

    def get_profile_emojis(text, redis_key=nil)
      profile_emojis_json = redis.get(redis_key)
      if profile_emojis_json.nil?
          return prepare_profile_emoji text, redis_key
      else
        if is_updated_within_ttl? text
          return prepare_profile_emoji text, redis_key
        end
        profile_emojis = JSON.load profile_emojis_json
        return profile_emojis.map!(&:symbolize_keys)
      end
    end

    def prepare_profile_emoji(text, redis_key=nil)
      profile_emojis = scan_profile_emojis_from_text(text)
      return set_redis(profile_emojis, redis_key).nil? ? [] : profile_emojis
    end

    private

    def is_updated_within_ttl?(text)
      now = Time.now.to_i
      text.scan(PROFILE_EMOJI_RE) { |username|
        a = Account.find_by(username: username)
        next if a.nil?
        profile_emoji_obj = a.profile_emoji
        next if profile_emoji_obj.blank?
        return true if now - profile_emoji_obj.updated_at < REDIS_TTL + 5
      }
      return false
    end

    def scan_profile_emojis_from_text(text)
      usernames = []
      text.scan(PROFILE_EMOJI_RE).map { |username|
        a = Account.find_by(username: username)
        next if a.nil? or usernames.include? a.username
        usernames << a.username
        {
          # 'shortcode' and 'url' are matched to CustomEmoji.
          shortcode: a.username,
          url: full_asset_url(a.profile_emoji_static_url),
          original_url: full_asset_url(a.profile_emoji_original_url),
          account_id: a.id,
          account_url: short_account_url(a),
        }
      }.compact
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
