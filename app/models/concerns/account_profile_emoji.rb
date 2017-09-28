# frozen_string_literal: true

module AccountProfileEmoji
  extend ActiveSupport::Concern

  include Friends::ProfileEmojiExtension

  def profile_emojis
    get_profile_emojis all_display_text, redis_key
  end

  private

  def all_display_text
    return [display_name, note].join(' ')
  end

  def redis_key
    "profile_emojis:account:#{self.id}"
  end
end

test
