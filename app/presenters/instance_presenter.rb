# frozen_string_literal: true

class InstancePresenter
  delegate(
    :closed_registrations_message,
    :site_contact_email,
    :open_registrations,
    :site_title,
    :site_short_description,
    :site_description,
    :site_extended_description,
    :site_terms,
    to: Setting
  )

  def contact_account
    Account.find_local(Setting.site_contact_username.gsub(/\A@/, ''))
  end

  def user_count
    Rails.cache.fetch('user_count') { User.confirmed.joins(:account).merge(Account.without_suspended).count }
  end

  def status_count
    Rails.cache.fetch('local_status_count') { Account.local.sum(:statuses_count) }
  end

  def domain_count
    Rails.cache.fetch('distinct_domain_count') { Account.distinct.count(:domain) }
  end

  def version_number
    Mastodon::Version
  end

  def source_url
    Mastodon::Version.source_url
  end

  def niconico_associated_count
    Rails.cache.fetch('niconico_associated_count') { User.where.not(uid: nil).count }
  end
  
  def thumbnail
    @thumbnail ||= Rails.cache.fetch('site_uploads/thumbnail_image') { SiteUpload.find_by(var: 'thumbnail') }
  end

  def hero
    @hero ||= Rails.cache.fetch('site_uploads/hero_image') { SiteUpload.find_by(var: 'hero') }
  end

  def mascot
    @mascot ||= Rails.cache.fetch('site_uploads/mascot') { SiteUpload.find_by(var: 'mascot') }
  end
end
