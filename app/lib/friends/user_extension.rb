# frozen_string_literal: true
module Friends
  module UserExtension
    extend ActiveSupport::Concern

    def nico_url(force = false)
      uid && (force || !hide_oauth) ? "http://www.nicovideo.jp/user/#{uid}" : nil
    end
  end
end
