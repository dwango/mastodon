# frozen_string_literal: true

module AccountProfileEmoji
  extend ActiveSupport::Concern

  include Friends::ProfileEmojiExtension

  included do
    before_create :set_profile_emojis
  end

  def profile_emojis
    get_profile_emojis all_display_text, redis_key
  end

  private

  def set_profile_emojis
    prepare_profile_emoji all_display_text, redis_key
  end

  def all_display_text
    return [display_name, note].join('  ')
  end

  def redis_key
    "profile_emojis:account:#{self.id}"
  end
end
