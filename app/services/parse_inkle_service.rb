class ParseInkleService
  attr_accessor :segments

  def initialize(json_string)
    @segments = []
    @json = JSON.parse(json_string)
    first_id = @json['data'].try(:[], 'initial')
    @paragraphs = @json['data'].try(:[], 'stitches')
    @children = [{ id: first_id, parent_ids: []}]
    parse if @paragraphs.present?
  end

  def author
    @json['data'].try(:[], 'editorData').try(:[], 'authorName')
  end

  def title
    @json['title']
  end

  private

  def parse
    until @children.empty?
      child = @children.shift
      child_id = child[:id]
      parent_ids = child[:parent_ids]
      @segments << add_segment(child_id, parent_ids, @paragraphs.fetch(child_id))
    end
    normalize_segments
    @segments
  end

  def normalize_segments
    @segments.delete_if do |segment|
      @segment = segment
      update_segment
    end
  end

  def update_segment
    if has_single_parent_with_single_child?
      update_parent && update_children
      true
    end
  end

  def has_single_parent_with_single_child?
    @segment[:parent_ids].length == 1 && parent[:child_options] == @segment[:id]
  end

  def update_parent
    parent[:contents] += @segment[:contents]
    parent[:child_options] = @segment[:child_options]
  end

  def parent
    @segments.find do |segment|
      segment[:id] == @segment[:parent_ids].join(',')
    end
  end

  def update_children
    if @segment[:child_options].present?
      children.each do |child|
        child[:parent_ids].map! { |id| id == @segment[:id] ? parent[:id] : id }
      end
    end
  end

  def children
    @segments.select { |segment| children_ids.include? segment[:id] }
  end

  def children_ids
    if @segment[:child_options].is_a? String
      [@segment[:child_options]]
    else
      @segment[:child_options].map { |child_option| child_option.keys[0] }
    end
  end


  def add_segment(id, parent_ids, paragraph_data)
    @paragraph_data = paragraph_data
    {
      id: id,
      contents: content,
      child_options: child_options(id) || child_divert(id),
      parent_ids: parent_ids
    }
  end

  def contents(paragraph_data)
    @paragraph_data = paragraph_data
    if has_next_paragraph?
      return content + contents(@paragraphs.fetch(next_paragraph))
    else
      return content
    end
  end

  def has_next_paragraph?
    next_paragraph.present?
  end

  def has_options?
    options.present?
  end

  def next_paragraph
    @paragraph_data['content'].find do |content|
      content.is_a?(Hash) && content.has_key?('divert')
    end.try(:values).try(:[], 0)
  end

  def child_divert(parent_id)
    if has_next_paragraph?
      add_child next_paragraph, parent_id
      next_paragraph
    end
  end

  def child_options(parent_id)
    if has_options?
      child_options = options.map do |option|
        if option['linkPath'].present?
          add_child option['linkPath'], parent_id
          { option['linkPath'] => option['option'] }
        end
      end.compact
      child_options if child_options.present?
    end
  end

  def options
    @paragraph_data['content'].select do |content|
      content.is_a?(Hash) && content.has_key?('linkPath')
    end
  end

  def add_child(id, parent_id)
    child = @segments.find { |segment| segment[:id] == id }
    child = @children.find { |kid| kid[:id] == id } unless child.present?
    if child.present?
      child[:parent_ids] << parent_id
    else
      @children << { id: id, parent_ids: [parent_id] }
    end
  end

  def content
    [@paragraph_data['content'][0]]
  end
end
