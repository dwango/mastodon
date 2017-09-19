# frozen_string_literal: true

module StatusProfileEmoji
  extend ActiveSupport::Concern

  include Friends::ProfileEmojiExtension

  def profile_emojis
    get_profile_emojis all_display_text, redis_key
  end

  private

  def all_display_text
    return [spoiler_text, text].join(' ')
  end

  def redis_key
    "profile_emojis:status:#{self.id}"
  end
end
