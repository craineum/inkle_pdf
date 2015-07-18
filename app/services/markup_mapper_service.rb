class MarkupMapperService
  VOID_TAGS = 'void_tags'
  VOID_HTML_TAGS = 'void_html_tags'
  OPEN_TAGS = 'open_tags'
  END_TAGS = 'end_tags'
  HTML_TAGS = 'html_tags'
  TAG_PARAMS = [
    VOID_TAGS,
    VOID_HTML_TAGS,
    OPEN_TAGS,
    END_TAGS,
    HTML_TAGS
  ]

  attr_reader :tag_params

  def initialize(params)
    @tag_params = compact_tag_params(params)
  end

  def tags_mapping
    non_void_tags_mapping + void_tags_mapping
  end

  def void_tags_mapping
    froms = tag_params.fetch VOID_TAGS, []
    tos = tag_params.fetch VOID_HTML_TAGS, []
    return [] unless froms.size == tos.size
    froms.map.with_index do |tag, index|
      { from: Regexp.escape(tag), to: tos[index] }
    end
  end

  def non_void_tags_mapping
    from_starts = tag_params.fetch OPEN_TAGS, []
    from_ends = tag_params.fetch END_TAGS, []
    tos = tag_params.fetch HTML_TAGS, []
    return [] unless from_starts.size == tos.size && from_ends.size == tos.size
    from_starts.map.with_index do |tag, index|
      { from_start: Regexp.escape(tag),
        from_end: Regexp.escape(from_ends[index]),
        to: tos[index] }
    end
  end

  private

  def void_tag_params
    tag_params.select { |key, value| VOID_TAG_PARAMS.include? key }
  end

  def compact_tag_params(params)
    params.select { |key, value| TAG_PARAMS.include? key }.each do |key, tags|
      tags.reject!(&:empty?)
    end
  end
end
