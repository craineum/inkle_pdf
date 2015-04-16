class BookSegment
  include ActiveModel::Model
  extend Enumerable
  @@all = Array.new

  attr_accessor :id, :child_options, :contents, :page_end, :page_start,
    :parent_ids

  validates :id, presence: true
  validate :contents_is_array
  validates :page_end, numericality: true, allow_nil: true
  validates :page_start, numericality: true, allow_nil: true
  validate :parent_ids_is_array

  def initialize(attributes={})
    super
    @@all << self
  end

  def child_ids
    self.child_options = [] if child_options.blank?
    @child_ids ||= if child_options.is_a? Array
      child_options.map { |child_option| child_option.keys[0] }
    else
      [child_options]
    end
  end

  def child_option(child_id)
    if child_options.present? && child_options.is_a?(Array)
      child_options.find do |child_option|
        child_option.keys[0] == child_id
      end.values[0]
    end
  end

  def children
    @children || BookSegment.select { |segment| child_ids.include? segment.id }
  end

  def parents
    self.parent_ids = [] if parent_ids.blank?
    @parents || BookSegment.select do |segment|
      parent_ids.include? segment.id
    end
  end

  def self.each(&block)
    @@all.each { |item| block.call(item) }
  end

  def self.valid?
    @@all.all? { |item| item.valid? }
  end

  def self.add(segments)
    segments.each do |segment|
      new(segment.to_a)
    end
  end

  private

  def contents_is_array
    is_array(contents: contents)
  end

  def parent_ids_is_array
    is_array(parent_ids: parent_ids)
  end

  def is_array(attribute)
    name, value = attribute.first
    if !value.nil?
      errors.add(name, 'must be an array') unless value.is_a? Array
    end
  end
end
