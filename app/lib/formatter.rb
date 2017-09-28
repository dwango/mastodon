# frozen_string_literal: true

require 'singleton'
require_relative './sanitize_config'

class Formatter
  include Singleton
  include RoutingHelper
  include StreamEntriesHelper

  include ActionView::Helpers::TextHelper

  def format(status, options = {})
    if status.reblog?
      prepend_reblog = status.reblog.account.acct
      status         = status.proper
    else
      prepend_reblog = false
    end

    raw_content = status.text

    return reformat(raw_content) unless status.local?

    linkable_accounts = status.mentions.map(&:account)
    linkable_accounts << status.account

    html = raw_content
    html = "RT @#{prepend_reblog} #{html}" if prepend_reblog
    html = encode_and_link_urls(html, linkable_accounts)
    html = encode_profile_emojis(html, status.profile_emojis) if options[:profile_emojify]
    html = simple_format(html, {}, sanitize: false)
    html = html.delete("\n")

    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  def format_enquete(enquete)
    raw_enquete_info = JSON.parse(enquete)
    enquete_info = {}
    question_html = encode_and_link_urls(raw_enquete_info['question'])
    question_html = simple_format(question_html, {}, sanitize: false)
    question_html = question_html.delete("\n")
    enquete_info['question'] = question_html.html_safe # rubocop:disable Rails/OutputSafety
    enquete_info['items'] = raw_enquete_info['items'].map do |item|
      encode_and_link_urls(item)
    end
    enquete_info['ratios'] = raw_enquete_info['ratios']
    enquete_info['ratios_text'] = raw_enquete_info['ratios_text']
    enquete_info['type'] = raw_enquete_info['type']
    JSON.generate(enquete_info)
  end

  def format_display_name(account, options = {})
    display_name = display_name(account)
    return reformat(display_name) unless account.local?

    html = encode_and_link_urls(display_name)
    html = encode_profile_emojis(html, account.profile_emojis, false) if options[:profile_emojify]

    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  def reformat(html)
    sanitize(html, Sanitize::Config::MASTODON_STRICT).html_safe # rubocop:disable Rails/OutputSafety
  end

  def plaintext(status)
    return status.text if status.local?
    strip_tags(status.text)
  end

  def simplified_format(account, options = {})
    return reformat(account.note) unless account.local?

    html = encode_and_link_urls(account.note)
    html = encode_profile_emojis(html, account.profile_emojis) if options[:profile_emojify]
    html = simple_format(html, {}, sanitize: false)
    html = html.delete("\n")

    html.html_safe # rubocop:disable Rails/OutputSafety
  end

  def sanitize(html, config)
    Sanitize.fragment(html, config)
  end

  private

  def encode(html)
    HTMLEntities.new.encode(html)
  end

  def encode_and_link_urls(html, accounts = nil)
    entities = Extractor.extract_entities_with_indices(html, extract_url_without_protocol: false)

    rewrite(html.dup, entities) do |entity|
      if entity[:url]
        link_to_url(entity)
      elsif entity[:hashtag]
        link_to_hashtag(entity)
      elsif entity[:screen_name]
        link_to_mention(entity, accounts)
      elsif entity[:niconico_link]
        link_to_niconico(entity)
      end
    end
  end

  def encode_profile_emojis(html, profile_emojis, embed_links = true)
    return html if profile_emojis == nil || profile_emojis.empty?

    profile_emoji_map = profile_emojis.map do |e|
      REST::ProfileEmojiSerializer.new(e).to_h
    end.map do |e|
      [e[:shortcode], e]
    end.to_h

    i = -1
    inside_tag = false
    inside_colon = false
    shortname = ''
    shortname_start_index = -1
    while i + 1 < html.size
      i += 1
      if html[i] == '<'
        inside_tag = true
      elsif inside_tag && html[i] == '>'
        inside_tag = false
      elsif !inside_tag
        if !inside_colon && html[i] == ':'
          inside_colon = true
          shortname = ''
          shortname_start_index = i
        elsif inside_colon && html[i] == ':'
          inside_colon = false
          stripped_shortname = shortname[1..-1]
          emoji = profile_emoji_map[stripped_shortname]
          if shortname[0] == '@' && emoji
            if embed_links
              replacement = "<a href=\"#{emoji[:account_url]}\" class=\"profile-emoji\" data-account-name=\"#{stripped_shortname}\">" \
                          +   "<img draggable=\"false\" class=\"emojione\" alt=\":#{shortname}:\" title=\":#{shortname}:\"  src=\"#{emoji[:url]}\" />" \
                          + "</a>"
            else
              replacement = "<img draggable=\"false\" class=\"emojione\" alt=\":#{shortname}:\" title=\":#{shortname}:\" src=\"#{emoji[:url]}\" />"
            end
            before_html = shortname_start_index.positive? ? html[0..shortname_start_index - 1] : ''
            html = before_html + replacement + html[i + 1..-1]
            i = shortname_start_index + replacement.size - 1
          else
            i -= 1
          end
        elsif inside_colon && html[i] != ' '
          shortname += html[i]
        end
      end
    end

    html
  end

  def rewrite(text, entities)
    chars = text.to_s.to_char_a

    # Sort by start index
    entities = entities.sort_by do |entity|
      indices = entity.respond_to?(:indices) ? entity.indices : entity[:indices]
      indices.first
    end

    result = []

    last_index = entities.reduce(0) do |index, entity|
      indices = entity.respond_to?(:indices) ? entity.indices : entity[:indices]
      result << encode(chars[index...indices.first].join)
      result << yield(entity)
      indices.last
    end

    result << encode(chars[last_index..-1].join)

    result.flatten.join
  end

  def link_to_url(entity)
    normalized_url = Addressable::URI.parse(entity[:url]).normalize
    html_attrs     = { target: '_blank', rel: 'nofollow noopener' }

    Twitter::Autolink.send(:link_to_text, entity, link_html(entity[:url]), normalized_url, html_attrs)
  rescue Addressable::URI::InvalidURIError, IDN::Idna::IdnaError
    encode(entity[:url])
  end

  def link_to_mention(entity, linkable_accounts)
    acct = entity[:screen_name]

    return link_to_account(acct) unless linkable_accounts

    account = linkable_accounts.find { |item| TagManager.instance.same_acct?(item.acct, acct) }
    account ? mention_html(account) : "@#{acct}"
  end

  def link_to_account(acct)
    username, domain = acct.split('@')

    domain  = nil if TagManager.instance.local_domain?(domain)
    account = Account.find_remote(username, domain)

    account ? mention_html(account) : "@#{acct}"
  end

  def link_to_hashtag(entity)
    hashtag_html(entity[:hashtag])
  end

  def link_to_niconico(entity)
    nl = entity[:niconico_link]

    "<a href=\"#{nl.to_href}\" rel=\"nofollow noopener\" target=\"_blank\"><span>#{nl.text}</span></a>"
  end

  def link_html(url)
    url    = Addressable::URI.parse(url).to_s
    prefix = url.match(/\Ahttps?:\/\/(www\.)?/).to_s
    text   = url[prefix.length, 30]
    suffix = url[prefix.length + 30..-1]
    cutoff = url[prefix.length..-1].length > 30

    "<span class=\"invisible\">#{encode(prefix)}</span><span class=\"#{cutoff ? 'ellipsis' : ''}\">#{encode(text)}</span><span class=\"invisible\">#{encode(suffix)}</span>"
  end

  def hashtag_html(tag)
    "<a href=\"#{tag_url(tag.downcase)}\" class=\"mention hashtag\" rel=\"tag\">#<span>#{tag}</span></a>"
  end

  def mention_html(account)
    "<span class=\"h-card\"><a href=\"#{TagManager.instance.url_for(account)}\" class=\"u-url mention\">@<span>#{account.username}</span></a></span>"
  end
end
