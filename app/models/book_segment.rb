class BookSegment
  include ActiveModel::Model
  extend Enumerable
  @@all = Array.new

  attr_accessor :id, :contents, :page_start, :page_end

  validates :id, presence: true
  validates :page_start, numericality: true, allow_nil: true
  validates :page_end, numericality: true, allow_nil: true
  validate do
    if !contents.nil?
      errors.add(:contents, 'must be an array') unless contents.is_a? Array
    end
  end

  def initialize(attributes={})
    super
    @@all << self
  end

  def self.each(&block)
    @@all.each { |item| block.call(item) }
  end

  def self.valid?
    @@all.all? { |item| item.valid? }
  end

  def self.add(*segments)
    segments.each do |segment|
      byebug
      new(segment.to_a)
    end
  end
end
