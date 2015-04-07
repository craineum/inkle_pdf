class ParseInkleService
  def initialize(json_string, first_id)
    @json_hash = JSON.parse(json_string)
    @first_id = first_id
    @segments = []
  end

  def parse
    @segments << segment(@first_id, @json_hash.fetch(@first_id))
  end

  private

  def segment(id, paragraph_data)
    { id: id, contents: contents(paragraph_data) }
  end

  def contents(paragraph_data)
    @paragraph_data = paragraph_data
    if has_child?
      child_paragraph = @json_hash.delete(child)
      return content + contents(child_paragraph)
    else
      return content
    end
  end

  def has_child?
    @paragraph_data['content'][1] and child
  end

  def child
    @paragraph_data['content'][1]['divert']
  end

  def content
    [@paragraph_data['content'][0]]
  end
end
