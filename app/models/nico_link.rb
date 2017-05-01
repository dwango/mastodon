# frozen_string_literal: true

class NicoLink
  BASE_URI = URI.parse('https://nico.ms')

  TEMPORAL_TYPES = %w(lv sm so).freeze
  NON_TEMPORAL_TYPES = %w(co ch im mg bk td kn gm nc).freeze

  NICO_ID_RE = %r{(#{[].concat([TEMPORAL_TYPES, NON_TEMPORAL_TYPES]).join('|')})(\d+)}
  NICO_ID_RE_FULLSTR = %r{\A#{NICO_ID_RE}\z}

  TIME_RE = %r{\d{1,2}:[0-5]\d}
  TIME_RE_FULLSTR = %r{\A#{TIME_RE}\z}

  NICOLINK_RE = %r{(?<prefix>^|[^\/\)\w])(?<nico_id>#{NICO_ID_RE})(#(?<time>#{TIME_RE}))?}

  def self.parse(nicolink)
    m = NICOLINK_RE.match(nicolink)
    NicoLink.new(m[:nico_id], m[:time], m[:prefix])
  end

  attr_reader :text, :prefix

  def initialize(nico_id, time = nil, prefix = '')
    @text = nico_id
    process_nico_id(nico_id)
    process_time(time)
    @text += "##{time}" if time?
    @prefix = prefix
  end

  def to_href
    href = BASE_URI + @nico_id
    href.query = URI.encode_www_form(from: @from_sec) if time?
    href.normalize.to_s
  end

  private

  def process_nico_id(nico_id)
    @nico_id = nico_id

    m = NICO_ID_RE_FULLSTR.match(@nico_id)
    @type = m[1] unless m.nil?
  end

  def process_time(time)
    time = time.to_s
    return unless temporal?
    return unless TIME_RE_FULLSTR.match?(time)

    min, sec = time.split(':').map(&:to_i)
    sec += min * 60

    @from_sec = sec unless sec <= 0
  end

  def temporal?
    TEMPORAL_TYPES.include?(@type)
  end

  def time?
    !@from_sec.nil?
  end
end
