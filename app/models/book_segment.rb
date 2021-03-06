class BookSegment
  include ActiveModel::Model

  attr_accessor :id, :child_options, :contents, :page_end, :page_start,
    :parent_ids

  validates :id, presence: true
  validate :contents_is_array
  validates :page_end, numericality: true, allow_nil: true
  validates :page_start, numericality: true, allow_nil: true
  validate :parent_ids_is_array

  def initialize(segments, attributes={})
    super attributes
    @segments = segments
  end

  def child_ids
    self.child_options = [] if child_options.blank?
    @child_ids ||= if child_options.is_a? Array
      child_options.map { |child_option| child_option.keys[0] }
    else
      [child_options]
    end
  end

  def children
    @children || @segments.select { |segment| child_ids.include? segment.id }
  end

  def footer_end
    [{ page: page_end, footers: ['<b>The End</b>'] }] if footer_end?
  end

  def footer_end?
    child_options.blank?
  end

  def footer_next
    (page_start..page_end - 1).map do |number|
      { page: number, footers: ['Turn to the next page'] }
    end if footer_next?
  end

  def footer_next?
    page_start != page_end
  end

  def footer_options
    if footer_options?
      [{ page: page_end, footers: options }]
    end
  end

  def footer_options?
    if page_end.present? && children.present?
      children.all? { |child| child.page_start.present? }
    end
  end

  def footers
    if footers?
      [footer_end, footer_next, footer_options, parents_footers].compact.flatten
    end
  end

  def footers?
    footer_end? || footer_next? || footer_options? || parents_footers?
  end

  def parents
    self.parent_ids = [] if parent_ids.blank?
    @parents || @segments.select do |segment|
      parent_ids.include? segment.id
    end
  end

  def parents_footers
    parents.map { |parent| parent.footer_options }.flatten.compact if parents_footers?
  end

  def parents_footers?
    parents.any? { |parent| parent.footer_options? } if parents.present?
  end

  private

  def child(id)
    children.find { |child| id.include? child.id }
  end

  def contents_is_array
    is_array(contents: contents)
  end

  def is_array(attribute)
    name, value = attribute.first
    if !value.nil?
      errors.add(name, 'must be an array') unless value.is_a? Array
    end
  end

  def options
    if child_options.is_a? Array
      child_options.map do |child_option|
        option_string = child_option.values[0]
        child_page = child(child_option.keys[0]).page_start.to_s
        '<b>' + option_string + '</b> - Turn to page ' + child_page
      end
    else
      ['Turn to page ' + children.first.page_start.to_s]
    end
  end

  def parent_ids_is_array
    is_array(parent_ids: parent_ids)
  end
end
