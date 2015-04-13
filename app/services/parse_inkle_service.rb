class ParseInkleService
  def initialize(json_string, first_id)
    @json_hash = JSON.parse(json_string)
    @segments = []
    @children = [{ id: first_id, parent_ids: []}]
  end

  def parse
    until @children.empty?
      child = @children.shift
      child_id = child[:id]
      parent_ids = child[:parent_ids]
      @segments << add_segment(child_id, parent_ids, @json_hash.fetch(child_id))
    end
    @segments
  end

  private

  def add_segment(id, parent_ids, paragraph_data)
    {
      id: id,
      contents: contents(paragraph_data),
      child_options: child_options(id),
      parent_ids: parent_ids
    }
  end

  def contents(paragraph_data)
    @paragraph_data = paragraph_data
    if has_next_paragraph?
      return content + contents(@json_hash.fetch(next_paragraph))
    else
      return content
    end
  end

  def has_next_paragraph?
    @paragraph_data['content'][1] and next_paragraph
  end

  def has_options?
    @paragraph_data['content'][1] and @paragraph_data['content'][1]['linkPath']
  end

  def next_paragraph
    @paragraph_data['content'][1]['divert']
  end

  def child_options(parent_id)
    if has_options?
      options.map do |option|
        add_child option['linkPath'], parent_id
        { option['linkPath'] => option['option'] }
      end
    end
  end

  def options
    (1..@paragraph_data['content'].length - 1).map do |option|
      if @paragraph_data['content'][option]['linkPath']
        @paragraph_data['content'][option]
      end
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
